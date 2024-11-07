//
//  URLSessionable.swift
//  APOD
//
//  Created by 홍진표 on 11/7/24.
//

import Foundation

// MARK: - Protocol for MOCK/REAL
/// Network Test 시, URLSession의 동작을 모방하기 위한 Protocol
protocol URLSessionable {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask
}

// MARK: - Conform the protocol
extension URLSession: URLSessionable { }
