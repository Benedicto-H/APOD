//
//  Endpoint.swift
//  APOD
//
//  Created by 홍진표 on 11/10/24.
//

import Foundation

/// `Endpoint`: 일반적으로 API 또는 네트워크 서비스에서 Client가 Server와 인터랙션 할 수 있도록 제공되는 특정 URL을 의미
/// 즉, Client가 데이터를 요청하거나 Server에 요청을 보내는 대상 위치
/// `Endpoint = URL 경로 + HTTP 메서드`로 정의됨

/// equal to `protocol RequestResponsable: Requestable, Responsable { }`
typealias RequestResponsable = Requestable & Responsable

class Endpoint<R>: RequestResponsable {
    
    //  Response 타입을 미리 정의하여, Endpoint 객체 하나만 request쪽에 넘기면 request()의 Response 제네릭에 적용
    /// Responsable Pr의 Response 타입을 R로 정의
    typealias Response = R
    
    /**
     `typealias`: 기존 타입에 대한 별칭
     
     Endpoint 객체를 만들 때, Response 타입을 명시
     */
    
    var baseURL: String
    var path: String
    var method: HTTPMethod
    var queryParams: Encodable?
    var bodyParams: Encodable?
    var headers: [String : String]?
    var sampleData: Data?
    
    init(baseURL: String,
         path: String = "",
         method: HTTPMethod = .get,
         queryParams: Encodable? = nil,
         bodyParams: Encodable? = nil,
         headers: [String : String]? = [:],
         sampleData: Data? = nil) {
        
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryParams = queryParams
        self.bodyParams = bodyParams
        self.headers = headers
        self.sampleData = sampleData
    }
}
