//
//  ProviderImpl.swift
//  APOD
//
//  Created by 홍진표 on 11/10/24.
//

import Foundation

// MARK: - ProviderImpl
final class APIProvider: Provider {
    
    /// `class var` vs `static let(var)`
    /// class var: 클래스 수준의 속성. 즉, 클래스의 모든 인스턴스가 공유될 수 있고 반드시 하나의 인스턴스를 가질 필요가 없음 (Anti-Singleton)
    /// static let(var): Singleton
    class var shared: APIProvider {
        get {
            return APIProvider()
        }
    }
    
    private let session: URLSessionable
    
    /// URLSession을 주입받음.
    /// 테스트 시 MockURLSession을 주입.
    init(session: URLSessionable = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - [Pr] Provider Methods Impl
    func request<R, E>(with endpoint: E, completionHandler: @escaping (Result<R, any Error>) -> Void) where R : Decodable, R == E.Response, E : RequestResponsable {
        
        do {
            let urlRequest: URLRequest = try endpoint.getURLRequest()
            
            session.dataTask(with: urlRequest) { (data, response, error) in
                /// dataTask(with:completionHandler:)의 completionHandler는 Background Thread에서 호출됨
                /// [Important] The completion handler is called on a different Grand Central Dispatch queue than the one that created the task.
                /// ref. https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory
                self.checkError(with: data, response, error) { result in
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            completionHandler(self.decode(with: data))
                        }
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                }
            }.resume()
        } catch {
            completionHandler(.failure(NetworkError.urlRequestError(error)))
        }
    }
    
    func request(url: URL, completionHandler: @escaping (Result<Data, any Error>) -> Void) {
        
        session.dataTask(with: url) { (data, response, error) in
            self.checkError(with: data, response, error) { result in
                completionHandler(result)
            }
        }.resume()
    }
    
    // MARK: - PRIVATE Methods
    private func checkError(with data: Data?, _ response: URLResponse?, _ error: (any Error)?, completionHandler: @escaping (Result<Data, Error>) -> Void) -> Void {
        
        if let error: (any Error) = error { completionHandler(.failure(error)); return }
        guard let response: HTTPURLResponse = response as? HTTPURLResponse else { completionHandler(.failure(NetworkError.unknownError)); return }
        
        guard (200..<300).contains(response.statusCode) else {
            
            switch response.statusCode {
            case (400..<500):
                /// Client Error 처리
                completionHandler(.failure(NetworkError.httpStatusError(.clientError(NetworkError.HTTPStatusError.ClientError(rawValue: response.statusCode)!))))
                return
            case (500..<600):
                /// Server Error 처리
                completionHandler(.failure(NetworkError.httpStatusError(.serverError(NetworkError.HTTPStatusError.ServerError(rawValue: response.statusCode)!))))
                return
            default:
                completionHandler(.failure(NetworkError.unknownError))
                return
            }
        }
        
        guard let data: Data = data else {
            completionHandler(.failure(NetworkError.emptyData))
            return
        }
        
        completionHandler(.success(data))
    }
    
    private func decode<T: Decodable>(with data: Data) -> Result<T, Error> {
        
        do {
            let decodedData: T = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedData)
        } catch {
            return .failure(NetworkError.emptyData)
        }
    }
}
