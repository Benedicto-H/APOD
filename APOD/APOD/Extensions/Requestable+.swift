//
//  Requestable+.swift
//  APOD
//
//  Created by 홍진표 on 11/10/24.
//

import Foundation

extension Requestable {
    
    func getURLRequest() throws -> URLRequest {
        
        let url: URL = try makeURL()
        var urlRequest: URLRequest = URLRequest(url: url)
        
        //  HTTP Body
        if (bodyParams != nil) {
            guard let bodyParams: [String : Any] = try bodyParams?.toDictionary() else { throw NetworkError.toDictionaryError }
            
            if (!bodyParams.isEmpty) {
                //  Dictionary 타입의 object를 JSON 형식으로 변환 후, httpBody에 저장하여 서버에 전송할 데이터 삽입
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParams)
            }
        }
        
        //  HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        //  HTTP Header
        if (headers != nil) {
            headers?.forEach({ k, v in
                urlRequest.setValue(v, forHTTPHeaderField: k)
            })
        }
        
        return urlRequest
    }
    
    func makeURL() throws -> URL {
        
        //  baseURL + path
        let fullPath: String = "\(baseURL)\(path)"
        guard var urlComponents: URLComponents = URLComponents(string: fullPath) else { throw NetworkError.componentsError }
        
        //  (baseURL + path) + queryParams
        var urlQueryItems: [URLQueryItem] = []
        
        //  Encodable 타입의 object (JSON) -> Foundation object
//        guard let queryParams: [String : Any] = try queryParams?.toDictionary() else { throw NetworkError.toDictionaryError }
        guard let queryParams: [String : String] = queryParams else {
//            print("실패")
            throw NetworkError.componentsError
        }
        
//        print("???: \(queryParams)")
        //  Dictionary 타입의 Foundation object인 queryParams를 하나씩 추출해서 urlQueryItems에 추가
        queryParams.forEach { k, v in   //  k: Key, v: Value
            urlQueryItems.append(URLQueryItem(name: k, value: "\(v)"))
        }
        
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        
        guard let url: URL = urlComponents.url else { throw NetworkError.componentsError }
//        print("[URL]: \(url.absoluteString)")
        
        return url
    }
}
