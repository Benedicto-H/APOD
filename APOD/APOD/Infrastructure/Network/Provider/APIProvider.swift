//
//  ProviderImpl.swift
//  APOD
//
//  Created by 홍진표 on 11/10/24.
//

import Foundation

// MARK: - ProviderImpl
final class APIProvider: Provider {
    
    static let shared: APIProvider = APIProvider()
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
                        completionHandler(self.decode(with: data))
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
    
    /// `Async/await`
    func request<R, E>(with endpoint: E) async throws -> R where R : Decodable, R == E.Response, E : RequestResponsable {
        
        do {
            let request = try endpoint.getURLRequest()
            
            let (data, response) = try await session.data(for: request)
            let safeData = try await self.checkError(with: data, response)
            return try await self.decode(with: safeData)
        } catch {
            throw NetworkError.urlRequestError(error)
        }
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
    
    /// `Async/await`
    private func checkError(with data: Data, _ response: URLResponse) async throws -> Data {
        
        guard let response = response as? HTTPURLResponse else { throw NetworkError.unknownError }
        
        guard (200..<300) ~= response.statusCode else {
            
            switch response.statusCode {
            case (400..<500):
                throw NetworkError.httpStatusError(.clientError(NetworkError.HTTPStatusError.ClientError(rawValue: response.statusCode)!))
            case (500..<600):
                throw NetworkError.httpStatusError(.serverError(NetworkError.HTTPStatusError.ServerError(rawValue: response.statusCode)!))
            default:
                throw NetworkError.unknownError
            }
        }
        
        guard !data.isEmpty else { throw NetworkError.emptyData }
        
        return data
    }
    
    private func decode<T>(with data: Data) async throws -> T where T: Decodable {
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch { throw NetworkError.emptyData }
    }
}
