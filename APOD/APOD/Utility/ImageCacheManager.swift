//
//  ImageLoader.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation
import UIKit

// MARK: - ImageCacheManager
final class ImageCacheManager {
    
    /// `Memory Cache`
    private static let imageCache: NSCache<NSString, UIImage> = {
        let cache: NSCache<NSString, UIImage> = NSCache<NSString, UIImage>()
        
        /// 메모리 캐시 정책
        /// case 1. `totalCostLimit`: 갯수와 상관없이, 저장되는 데이터들의 `cost`에 제한을 둠
        /// case 2. `countLimit`: 저장되는 데이터의 갯수에 제한을 둠
        cache.totalCostLimit = 1024 * 1024 * 10 //  totalCostLimit을 10MB로 설정
        
        return cache
    }()
    
    /// `Disk Cache`
    private static let diskCacheDirectory: URL = {
        /// 캐시 디렉토리 경로 설정
        guard let path: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError("캐시 디렉토리를 찾을 수 없음.")
        }
        
        /// Caches의 ImageCache 서브폴더 생성
        let directory: URL = URL(fileURLWithPath: path).appendingPathComponent("ImageCache")
        
        /// 캐시 디렉토리가 없으면 생성
        if (!FileManager.default.fileExists(atPath: directory.path)) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("디스크 캐시 디렉토리 생성 실패: \(error.localizedDescription)")
            }
        }
        
        return directory
    }()
    
    private init() {}
    
    // MARK: - Caching FLOW
    /// `1. 메모리 캐시 검사 -> (실패) -> 2. 디스크 캐시 검사 -> (실패) -> 3. 메모리/디스크 캐시에 각각 데이터 추가 후 반환`
    ///
    /// 1. `Memory Cache 검사`
    private static func checkMemoryCache(key: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void {
        
        guard let image: UIImage = imageCache.object(forKey: key as NSString) else {
            /// 메모리 캐시 검사 실패
            print("+-----> 메모리 캐시에 이미지가 없음.")
            completion(.failure(.invalidMemoryCache))
            return
        }
        
        print("========== 이미지가 메모리 캐시에 존재 ========== \n")
        
        /// 있으면 반환
        completion(.success(image))
    }
    
    /// 2. `Disk Cache 검사`
    private static func checkDiskCache(key: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void {
        
        guard let image: UIImage = loadDiskCache(forKey: key),
              let cost: Int = image.jpegData(compressionQuality: 1.0)?.count else {
            /// 디스크 캐시 검사 실패
            print("+-----> 디스크 캐시에 이미지가 없음.")
            completion(.failure(.invalidDiskCache))
            return
        }
        
        print("========== 이미지가 디스크 캐시에 존재 ========== \n")
        
        /// 메모리 캐시에 저장될 데이터의 비용 (크기) 설정하여, 디스크 캐시의 이미지를 메모리 캐시에 저장
        imageCache.setObject(image, forKey: key as NSString, cost: cost)
        
        /// 있으면 반환
        completion(.success(image))
    }
    
    /// 2-1. `디스크 캐시 로드`
    private static func loadDiskCache(forKey key: String) -> UIImage? {
        
        let fileURL: URL = diskCacheDirectory.appending(path: key)
        
        /// `캐시 만료 정책`
        /// 만료 시간을 체크하여 캐시 유효성 검사
        guard let attributes: [FileAttributeKey: Any] = try? FileManager.default.attributesOfItem(atPath: fileURL.path()),
              let modificationDate: Date = attributes[.modificationDate] as? Date else { return nil }
        
        /// 캐시 만료 타임 24시간 설정
        let expirationTime: TimeInterval = (60 * 60) * 24
        
        if (Date().timeIntervalSince(modificationDate) > expirationTime) {
            /// 만료된 경우 파일 삭제
            try? FileManager.default.removeItem(at: fileURL)
            
            return nil
        }
        
        guard let data: Data = try? Data(contentsOf: fileURL) else { return nil }
        
        return UIImage(data: data)
    }
    
    /// 3. `메모리/디스크 캐시에 각각 데이터 추가 후 반환`
    private static func saveDataIntoCache(url: URL, key: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void {
        
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
            if (data.count > imageCache.totalCostLimit) {
                print("+-----> 메모리 캐시에 데이터를 저장할 수 없음")
            } else {
                /// `totalCostLimit`의 크기보다 작다면 메모리 캐싱
                guard let cost: Int = image.jpegData(compressionQuality: 1.0)?.count else { return }
                
                imageCache.setObject(image, forKey: key as NSString, cost: cost)
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
    
    /// `캐시로부터 데이터 로드`
    static func loadData(from url: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) -> Void {
        
        DispatchQueue.global(qos: .utility).async {
            /// URL 형식으로 변환
            guard let url: URL = URL(string: url) else {
                completion(.failure(.invalidURL))
                return
            }
            
            /// Cache Key 생성
            let cacheKey: String = url.lastPathComponent
            
            /// 1. `Memory Cache 검사`
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
                
                /// 2. `Disk Cache 검사`
                print("********** 디스크 캐시 검사 시작 **********")
                checkDiskCache(key: cacheKey) { result in
                    switch result {
                    case .success(let diskCachedImage):
                        DispatchQueue.main.async {
                            completion(.success(diskCachedImage))
                        }
                        return
                    case .failure:
                        completion(.failure(.invalidDiskCache))
                    }
                    
                    /// 3. `Memory Cache와 Disk Cache에 각각 데이터 추가 후 반환`
                    print("********** 메모리/디스크 캐시 추가 시작 **********")
                    saveDataIntoCache(url: url, key: cacheKey) { result in
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
}
