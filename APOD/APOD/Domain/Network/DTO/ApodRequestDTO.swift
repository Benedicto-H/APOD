//
//  ApodDTO.swift
//  APOD
//
//  Created by 홍진표 on 11/30/24.
//

import Foundation

struct ApodRequestDTO: Encodable, APIKeyProvider {
    
    let apiKey: String = Bundle.main.apiKey
    
    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
    }
}
