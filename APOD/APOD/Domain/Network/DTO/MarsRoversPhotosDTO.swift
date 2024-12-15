//
//  MarsRoversPhotosDTO.swift
//  APOD
//
//  Created by 홍진표 on 11/30/24.
//

import Foundation

struct MarsRoversPhotosDTO: Encodable, APIKeyProvider {
    
    let apiKey: String = Bundle.main.apiKey
    let sol: Int
    let camera: String
    
    init(sol: Int, camera: String) {
        self.sol = sol
        self.camera = camera
    }
    
    enum CodingKeys: String, CodingKey {
        case sol, camera
        case apiKey = "api_key"
    }
}
