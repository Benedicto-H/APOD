//
//  MarsRoversPhotosDTO.swift
//  APOD
//
//  Created by 홍진표 on 11/30/24.
//

import Foundation

struct MarsRoversPhotosDTO: Encodable, APIKeyProvider {
    
    let apiKey: String = Bundle.main.apiKey
    let sol: Int = 1000
    let camera: String = "fhaz"
    
    enum CodingKeys: String, CodingKey {
        case sol, camera
        case apiKey = "api_key"
    }
}
