//
//  Provider.swift
//  APOD
//
//  Created by 홍진표 on 11/10/24.
//

import Foundation

protocol Provider {
    /**
     Provider에서 Endpoint 객체를 받으면, 따로 Response 타입을 넘기지 않아도 되도록 설계
     */
    
    //  특정 responsable이 존재하는 request
    //  Endcode 할 수 있는 타입을 전달하여 해당 타입과 동일한 객체를 서버로부터 얻고자 하는 경우
    
    /// equal to `func request<R, E>(with endpoint: E, completionHandler: @escaping (Result<R, Error>) -> Void) -> Void where R: Decodable, R == E.Response, E: RequestResponsable`
    /// [CONDITION]: `where R: Decodable, R == E.Response, E: RequestResponsable`
    /// -> R은 Decodable 해야하고, Endpoint의 Response 타입과 일치해야하며 E는 Endpoint 조건을 만족해야한다.
    func request<R: Decodable, E: RequestResponsable>(with endpoint: E, completionHandler: @escaping (Result<R, Error>) -> Void) -> Void where E.Response == R  //  Encodable한 Request모델을 통해서 Decodable한 Response를 받는 request
    
    //  data를 얻는 request
    func request(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) -> Void  //  단순히 URL을 request()로 주어, Data를 얻는 request()
    
    /// `Async/await`
    func request<R, E>(with endpoint: E) async throws -> R where R: Decodable, R == E.Response, E: RequestResponsable
}
