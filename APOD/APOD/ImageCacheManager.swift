//
//  ImageLoader.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation
import UIKit

final class ImageCacheManager {
    
    private static let imageCache: NSCache<NSString, UIImage> = NSCache<NSString, UIImage>()
    
    private init() {}
    
    static func loadImage(from url: String, completion: @escaping (Result<UIImage, ImageCacheManagerError>) -> Void) {
        
        /// URL 형식으로 변환
        guard let url: URL = URL(string: url) else { 
            completion(.failure(.invalidURL))
            return
        }
        
        /// `imageCache에 있으면 반환`
        if let image: UIImage = imageCache.object(forKey: url.lastPathComponent as NSString) {
            print("========== 이미지가 캐시에 존재 ========== \n")
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
            
            return
        }
        
        /// `imageCache에 없으면 추가 후 반환`
        DispatchQueue.global(qos: .background).async {
            print("========== 이미지가 캐시에 없음 ========== \n")
            
            do {
                /// 데이터 타입 반환, 이미지 변환
                guard let data: Data = try? Data(contentsOf: url),
                      let image: UIImage = UIImage(data: data) else {
                    completion(.failure(.imageCreationFailed))
                    return
                }
                
                /// imageCache에 추가
                imageCache.setObject(image, forKey: url.lastPathComponent as NSString)
                
                print("========== 이미지가 캐시에 추가됨! ========== \n")
                
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            } catch {
                print(error.localizedDescription)
                completion(.failure(.dataLoadingFailed(error)))
            }
        }
    }
}
