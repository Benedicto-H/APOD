//
//  MediaType.swift
//  APOD
//
//  Created by 홍진표 on 10/4/24.
//

import Foundation

// MARK: - 미디어 타입 정의
enum MediaType {
    case image(URL)
    case video(URL)
    
    init?(from url: String) {
        let baseURL: String = "https://www.youtube.com/embed/"
        
        if (url.contains(baseURL) == true) {
            guard let videoURL: URL = URL(string: url) else { return nil }
            self = .video(videoURL)
        } else {
            guard let imageURL: URL = URL(string: url) else { return nil }
            self = .image(imageURL)
        }
    }
}
