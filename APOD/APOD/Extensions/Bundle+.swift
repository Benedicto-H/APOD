//
//  Bundle+.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

// MARK: - Extension Bundle
extension Bundle {
    
    var apiKey: String {
        get {
            guard let key: String = Bundle.main.object(forInfoDictionaryKey: "NASA_APIKey") as? String else {
                fatalError("NASA_API_KEY not found in Info.plist.")
            }
            
            return key
        }
    }
}
