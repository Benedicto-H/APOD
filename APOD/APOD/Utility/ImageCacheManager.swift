//
//  ImageLoader.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation
import UIKit

protocol ImageCacheManagerDelegate: AnyObject {
    
    /// `completionHandler`
    func getImage(with url: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void
    func checkMemoryCache(key: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void
    func checkDiskCache(key: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void
    func saveImage(with url: URL, key: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void
    
    /// `Async/await`
    func getImage(with url: String) async throws -> UIImage
    func checkMemoryCache(with key: String) async throws -> UIImage
    func checkDiskCache(with key: String) async throws -> UIImage
    func saveImage(with url: URL, key: String) async throws -> UIImage
}

// MARK: - ImageCacheManager
final class ImageCacheManager: ImageCacheManagerDelegate {
    
    static let shared = ImageCacheManager()
    
    /// `Memory Cache`
    private var memoryCache = NSCache<NSString, UIImage>()
    
    /// `Disk Cache Directory`
    private var diskCacheDirectory: URL
    
    /// `FileManager Singleton Instance`
    private let FMdefault = FileManager.default
    
    private init() {
        /// 메모리 캐시 정책
        /// case 1. `totalCostLimit`: 갯수와 상관없이, 저장되는 데이터들의 `cost`에 제한을 둠
        /// case 2. `countLimit`: 저장되는 데이터의 갯수에 제한을 둠
        self.memoryCache.totalCostLimit = (1024 * 1024) * 10    //  메모리 캐시 크기 10MB 설정
        
        /// 디스크 캐시 디렉토리 경로 설정
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError("***** 디스크 캐시 디렉토리 경로를 찾을 수 없음 *****")
        }
        
        /// 디스크 캐시의 서브폴더 생성 (-> ImageCache)
        let directoryURL = URL(filePath: path).appending(path: "ImageCache")
        
        /// 디스크 캐시 디렉토리가 없으면 생성
        if !FMdefault.fileExists(atPath: directoryURL.path()) {
            do {
                try FMdefault.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                fatalError("***** 디스크 캐시 디렉토리 생성 실패: \(error.localizedDescription) *****")
            }
        }
        
        self.diskCacheDirectory = directoryURL
    }
    
    /// `메모리/디스크 캐시로부터 이미지 가져오기`
    func getImage(with url: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void {
        
        /// URL 형식으로 변환
        guard let url: URL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        /// Cache Key 생성
        let cacheKey: String = url.lastPathComponent
        
        print("********** 메모리 캐시 검사 시작 **********")
        checkMemoryCache(key: cacheKey) { result in
            switch result {
            case .success(let memoryCachedImage):
                DispatchQueue.main.async {
                    completion(.success(memoryCachedImage))
                }
                return
            case .failure:
                completion(.failure(.invalidMemoryCache))
            }
            
            print("********** 디스크 캐시 검사 시작 **********")
            self.checkDiskCache(key: cacheKey) { result in
                switch result {
                case .success(let diskCachedImage):
                    DispatchQueue.main.async {
                        completion(.success(diskCachedImage))
                    }
                    return
                case .failure:
                    completion(.failure(.invalidDiskCache))
                }
                
                print("********** 메모리/디스크 캐시 추가 시작 **********")
                DispatchQueue.global(qos: .utility).async {
                    self.saveImage(with: url, key: cacheKey) { result in
                        switch result {
                        case .success(let image):
                            DispatchQueue.main.async {
                                completion(.success(image))
                            }
                            return
                        case.failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Caching Flow
    /// `메모리 캐시 검사 -> (실패) -> 디스크 캐시 검사 -> (실패) -> 메모리/디스크 캐시에 각각 데이터 추가`
    ///
    /// `메모리 캐시 검사`
    func checkMemoryCache(key: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void {
        
        guard let image: UIImage = memoryCache.object(forKey: key as NSString) else {
            /// 메모리 캐시 검사 실패
            print("+-----> 메모리 캐시에 이미지가 없음.")
            completion(.failure(.invalidMemoryCache))
            return
        }
        
        print("========== 이미지가 메모리 캐시에 존재 ========== \n")
        
        /// 있으면 반환
        completion(.success(image))
    }
    
    /// `디스크 캐시 검사`
    func checkDiskCache(key: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void {
        
        self.getDiskCachedImage(forKey: key) { [weak self] image in
            guard let self: ImageCacheManager = self else { return }
            guard let image: UIImage = image, let cost: Int = image.jpegData(compressionQuality: 1.0)?.count else {
                /// 디스크 캐시 검사 실패
                print("+-----> 디스크 캐시에 이미지가 없음.")
                completion(.failure(.invalidDiskCache))
                return
            }
            
            print("========== 이미지가 디스크 캐시에 존재 ========== \n")
            
            /// 메모리 캐시에 저장될 데이터의 비용 (크기) 설정하여, 디스크 캐시의 이미지를 메모리 캐시에 저장
            memoryCache.setObject(image, forKey: key as NSString, cost: cost)
            
            /// 있으면 반환
            completion(.success(image))
        }
    }
    
    /// `디스크 캐시 이미지 가져오기`
    private func getDiskCachedImage(forKey key: String, completion: @escaping (UIImage?) -> Void) -> Void {
        
        let fileURL: URL = diskCacheDirectory.appending(path: key)
        
        /// `캐시 만료 정책`
        /// 만료 시간을 체크하여 캐시 유효성 검사
        guard let attributes: [FileAttributeKey: Any] = try? FileManager.default.attributesOfItem(atPath: fileURL.path()),
              let modificationDate: Date = attributes[.modificationDate] as? Date else { return }
        
        /// 캐시 만료 타임 24시간 설정
        let expirationTime: TimeInterval = (60 * 60) * 24
        
        if (Date().timeIntervalSince(modificationDate) > expirationTime) {
            /// 만료된 경우 파일 삭제
            try? FileManager.default.removeItem(at: fileURL)
            
            return
        }
        
        guard let data: Data = try? Data(contentsOf: fileURL) else { return }
        
        completion(UIImage(data: data))
    }
    
    /// `메모리/디스크 캐시에 각각 데이터 추가`
    func saveImage(with url: URL, key: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void {
        
        print("========== 이미지가 캐시에 없으므로 다운로드 ==========")
        do {
            /// 데이터 타입 반환, 이미지 변환
            let data: Data = try Data(contentsOf: url)
            guard let image: UIImage = UIImage(data: data) else {
                completion(.failure(.imageCreationFailed))
                return
            }
            
            /// 3-1. `메모리 캐시 추가`
            /// Condition: url을 통한 데이터의 크기가 메모리 캐시의 `totalCostLimit` 보다 크면 메모리 캐싱 불가능
            if (data.count > memoryCache.totalCostLimit) {
                print("+-----> 메모리 캐시에 데이터를 저장할 수 없음")
            } else {
                /// `totalCostLimit`의 크기보다 작다면 메모리 캐싱
                guard let cost: Int = image.jpegData(compressionQuality: 1.0)?.count else { return }
                
                memoryCache.setObject(image, forKey: key as NSString, cost: cost)
                print("========== 이미지가 메모리 캐시에 추가됨! ==========")
            }
            
            /// 3-2. `디스크 캐시 추가`
            guard let imageData: Data = image.jpegData(compressionQuality: 1.0) else { return }
            let fileURL: URL = diskCacheDirectory.appending(path: key)
            
            do {
                try imageData.write(to: fileURL)
                
                print("이미지 저장 경로: \(fileURL.path)")
                print("========== 이미지가 디스크 캐시에 추가됨! ==========")
                
                completion(.success(image))
            } catch {
                print("이미지 저장 실패: \(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
            completion(.failure(.imageLoadingFailed(error)))
        }
    }
}

// MARK: - ImageCacheManager+
extension ImageCacheManager {
    
    func getImage(with url: String) async throws -> UIImage {
        
        guard let url = URL(string: url) else { throw ImageCacheManagerError.invalidURL }
        
        let cacheKey = url.lastPathComponent
        
        do {
            print("1. 메모리 캐시 검사")
            return try await checkMemoryCache(with: cacheKey)
        } catch {
            print("1. (실패)")
            do {
                print("2. 디스크 캐시 검사")
                return try await checkDiskCache(with: cacheKey)
            } catch {
                print("2. (실패)")
                print("3. 메모리/디스크 캐시에 각각 데이터 추가 후 반환")
                return try await Task(priority: .utility) {
                    return try await saveImage(with: url, key: cacheKey)
                }.value
            }
        }
    }
    
    func checkMemoryCache(with key: String) async throws -> UIImage {
        
        print("[메모리 캐시 검사 시작]")
        
        guard let cachedImage = memoryCache.object(forKey: key as NSString) else {
            print("***** 메모리 캐시에 이미지가 없음 *****")
            throw ImageCacheManagerError.invalidMemoryCache
        }
        
        print("***** 메모리 캐시에 이미지가 있음 ***** \n")
        return cachedImage
    }
    
    func checkDiskCache(with key: String) async throws -> UIImage {
        
        print("[디스크 캐시 검사 시작]")
        
        guard let diskImage = await getDiskCachedImage(from: key),
              let cost = diskImage.jpegData(compressionQuality: 1.0)?.count else {
            print("***** 디스크 캐시에 이미지가 없음 *****")
            throw ImageCacheManagerError.invalidDiskCache
        }
        
        print("***** 디스크 캐시에 이미지가 있음 ***** \n")
        memoryCache.setObject(diskImage, forKey: key as NSString, cost: cost)
        
        return diskImage
    }
    
    private func getDiskCachedImage(from key: String) async -> UIImage? {
        
        let fileURL = diskCacheDirectory.appending(path: key)
        
        /// `캐시 만료 정책`
        /// 만료 시간을 검사하여 캐시 유효성 검사
        guard let attributes = try? FMdefault.attributesOfItem(atPath: fileURL.path()),
              let modificationDate = attributes[.modificationDate] as? Date else { return nil }
        
        let expirationTime = (60 * 60) * 24
        
        if Date().timeIntervalSince(modificationDate) > TimeInterval(expirationTime) { try? FMdefault.removeItem(at: fileURL) }
        
        guard let data = try? Data(contentsOf: fileURL),
              let diskCacheImage = UIImage(data: data) else { return nil }
        
        return diskCacheImage
    }
    
    func saveImage(with url: URL, key: String) async throws -> UIImage {
        
        print("[이미지가 모든 캐시에 없으므로 다운로드]")
        
        do {
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else { throw ImageCacheManagerError.imageCreationFailed }
            
            /// 메모리 캐시 저장
            if data.count > memoryCache.totalCostLimit {
                print("***** 메모리 캐시에 이미지를 저장할 수 없음 *****")
            } else {
                guard let cost = image.jpegData(compressionQuality: 1.0)?.count else { throw ImageCacheManagerError.imageCreationFailed }
                
                memoryCache.setObject(image, forKey: key as NSString, cost: cost)
                print("***** 이미지가 메모리 캐시에 추가됨 *****")
            }
            
            /// 디스크 캐시 저장
            guard let data = image.jpegData(compressionQuality: 1.0) else { throw ImageCacheManagerError.imageCreationFailed }
            let fileURL = diskCacheDirectory.appending(path: key)
            
            do {
                try data.write(to: fileURL)
                
                print("(디스크 캐시) 이미지 저장 경로: \(fileURL.path())")
                print("***** 이미지가 디스크 캐시에 추가됨 *****")
                
                return image
            } catch {
                print("(디스크) 이미지 저장 실패: \(error.localizedDescription)")
            }
        } catch { throw ImageCacheManagerError.imageLoadingFailed(error) }
        
        return UIImage()
    }
}
