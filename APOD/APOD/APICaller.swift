//
//  APICaller.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

final class APICaller {
    
    /// Creational Pattern: `Singleton`
    static let shared: APICaller = APICaller()
    
    fileprivate let baseURL: String = "https://api.nasa.gov/planetary/apod"
    fileprivate let apiKey: String = Bundle.main.apiKey
    
    private init() {}
    
    func fetchApod(completion: @escaping (Result<Apod, APIError>) -> Void) -> Void {
        
        guard let url: URL = URL(string: baseURL + "?api_key=\(apiKey)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        
        /// Request의 HTTP 메서드 설정
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            /// Response 상태 코드 검사
            guard (200..<300).contains((response as? HTTPURLResponse)!.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard let data: Data = data else {
                completion(.failure(APIError.invalidData))
                return
            }
            
            do {
                let decodedData: Apod = try JSONDecoder().decode(Apod.self, from: data)
                completion(.success(decodedData))
            } catch {
                print(error.localizedDescription)
                completion(.failure(APIError.decodingFailure))
            }
        }.resume()
    }
}
