//
//  APIKeyProvider.swift
//  APOD
//
//  Created by 홍진표 on 11/30/24.
//

import Foundation

protocol APIKeyProvider: Codable {
    var apiKey: String { get }
}
