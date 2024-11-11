//
//  ProviderImpl.swift
//  APOD
//
//  Created by 홍진표 on 11/10/24.
//

import Foundation

class ProviderImpl: Provider {
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - [Pr] Provider Methods Impl
    func request<R, E>(with endpoint: E, completionHandler: @escaping (Result<R, any Error>) -> Void) where R : Decodable, R == E.Response, E : RequestResponsable {
        
        do {
            let urlRequest: URLRequest = try endpoint.getURLRequest()
            
            session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                self?.checkError(with: data, response, error, completionHandler: { result in
                    guard let self: ProviderImpl = self else { return }
                    
                    switch result {
                    case .success(let data):
                        completionHandler(self.decode(with: data))
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                })
            }
        } catch {
            completionHandler(.failure(NetworkError.urlRequestError(error)))
        }
    }
    
    func request(url: URL, completionHandler: @escaping (Result<Data, any Error>) -> Void) {
        
        session.dataTask(with: url) { [weak self] (data, response, error) in
            self?.checkError(with: data, response, error, completionHandler: { result in
                completionHandler(result)
            })
        }.resume()
    }
    
    // MARK: - PRIVATE Methods
    private func checkError(with data: Data?, _ response: URLResponse?, _ error: (any Error)?, completionHandler: @escaping (Result<Data, Error>) -> Void) -> Void {
        
        if let error: (any Error) = error { completionHandler(.failure(error)); return }
        
        guard let response: HTTPURLResponse = response as? HTTPURLResponse else { completionHandler(.failure(NetworkError.unknownError)); return }
        
        
        guard (200..<300) ~= response.statusCode else {
            completionHandler(.failure(NetworkError.serverError(ServerError(rawValue: response.statusCode) ?? .unknown)))
//            if ((400..<500) ~= response.statusCode) {
//                if let clientError: ClientError = ClientError(rawValue: response.statusCode) {
//                    print("clientError: \(clientError)")
//                    completionHandler(.failure(NetworkError.httpStatusError(.clientError(clientError))))
//                    return
//                }
//            } else if ((500..<600) ~= response.statusCode) {
//                if let serverError: ServerError = ServerError(rawValue: response.statusCode) {
//                    print("serverError: \(serverError)")
//                    completionHandler(.failure(NetworkError.httpStatusError(.serverError(serverError))))
//                    return
//                }
//            }
            
            return
        }
        
        
        guard let data: Data = data else { completionHandler(.failure(NetworkError.emptyData)); return }
        
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
