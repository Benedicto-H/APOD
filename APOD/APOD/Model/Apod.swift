//
//  Apod.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

struct Apod: Codable {
    
    var copyright: String?
    var date: String?
    var explanation: String?
    var hdurl: String?
    var mediaType: String?
    var serviceVersion: String?
    var title: String?
    var url: String?
    
    /// `CodingKey Pr`를 통해 JSON 데이터의 Key를 Model의 프로퍼티에 맞게 치환
    enum CodingKeys: String, CodingKey {
        case copyright, date, explanation, hdurl, title, url
        case mediaType = "media_type"
        case serviceVersion = "service_version"
    }
}
