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
    
    /// for `Memory Cache`
    private static let imageCache: NSCache<NSString, UIImage> = NSCache<NSString, UIImage>()
    
    /// for `Disk Cache`
    static let diskCacheDirectory: URL = {
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
    
    static func loadImage(from url: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) {
        
        /// URL 형식으로 변환
        guard let url: URL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        /// Cache Key 생성
        let cacheKey: String = url.lastPathComponent
        
        /// 캐시 관리 및 무효화
        clearCache(forKey: cacheKey)
        
        /// `Memory Cache (imageCache)에 있으면 반환`
        if let cachedImage: UIImage = imageCache.object(forKey: cacheKey as NSString) {
            print("========== 이미지가 메모리 캐시에 존재 ========== \n")
            
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
            
            return
        }
        
        /// `Disk Cache (diskCacheDirectory)에 있으면 반환`
        if let diskCachedImage: UIImage = loadDiskCache(forKey: cacheKey) {
            print("========== 이미지가 디스크 캐시에 존재 ========== \n")
            
            /// 디스크 캐시의 이미지를 메모리 캐시에 저장
            imageCache.setObject(diskCachedImage, forKey: cacheKey as NSString)
            
            DispatchQueue.main.async {
                completion(.success(diskCachedImage))
            }
            
            return
        }
        
        /// `Memory Cache와 Disk Cache에 없으면 각각 추가 후 반환`
        DispatchQueue.global(qos: .background).async {
            print("========== 이미지가 캐시에 없으므로 다운로드 ========== \n")
            
            do {
                /// 데이터 타입 반환, 이미지 변환
                guard let data: Data = try? Data(contentsOf: url),
                      let image: UIImage = UIImage(data: data) else {
                    completion(.failure(.imageCreationFailed))
                    return
                }
                
                /// `Memory Cache에 추가`
                imageCache.setObject(image, forKey: cacheKey as NSString)
                
                print("========== 이미지가 캐시에 추가됨! ========== \n")
                
                /// `Disk Cache에 추가`
                saveDiskCache(image, forKey: cacheKey)
                print("========== 이미지가 디스크 캐시에 추가됨! ========== \n")
                
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            } catch {
                print(error.localizedDescription)
                completion(.failure(.imageLoadingFailed(error)))
            }
        }
    }
    
    private static func clearCache(forKey key: String) -> Void {
        
        /// 메모리 캐시 비우기
        imageCache.removeAllObjects()
        
        /// 디스크 캐시에서 당일 이미지 데이터를 제외한 모든 데이터 삭제
        do {
            guard let fileURLs: [URL] = try? FileManager.default.contentsOfDirectory(at: diskCacheDirectory, includingPropertiesForKeys: nil) else { return }
            for fileURL in fileURLs {
                /// 캐시 키가 fileURL의 마지막 경로와 같으면 제외
                if (fileURL.lastPathComponent != key) {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
            print("디스크 캐시의 최신화 된 데이터 이외에는 다 삭제됨")
        } catch {
            print("디스크 캐시 지우기 실패: \(error.localizedDescription)")
        }
    }
    
    private static func loadDiskCache(forKey key: String) -> UIImage? {
        
        let fileURL: URL = diskCacheDirectory.appending(path: key)
        guard let data: Data = try? Data(contentsOf: fileURL) else { return nil }
        
        var image: UIImage? = UIImage(data: data)
        
        return image
    }
    
    private static func saveDiskCache(_ image: UIImage, forKey key: String) -> Void {
        
        guard let data: Data = image.jpegData(compressionQuality: 1.0) else { return }
        let fileURL: URL = diskCacheDirectory.appending(path: key)
        
        do {
            try data.write(to: fileURL)
            
            print("이미지 저장 경로: \(fileURL.path)")
        } catch {
            print("이미지 저장 실패: \(error.localizedDescription)")
        }
    }
}
