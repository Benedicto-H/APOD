//
//  APICaller.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

final class NetworkManager {
    
    /// Creational Pattern: `Singleton`
    static let shared: NetworkManager = NetworkManager()
    
    fileprivate let baseURL: String = "https://api.nasa.gov/planetary/apod"
    fileprivate let apiKey: String = Bundle.main.apiKey
    
    private init() {}
    
    func fetchApod(completion: @escaping (Result<Apod, NetworkError>) -> Void) -> Void {
        
        guard let url: URL = URL(string: baseURL + "?api_key=\(apiKey)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        
        /// Request의 HTTP 메서드 설정
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            /// dataTask(with:completionHandler:)의 completionHandler는 Background Thread에서 호출됨
            /// [Important] The completion handler is called on a different Grand Central Dispatch queue than the one that created the task.
            /// ref. https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory
            
            guard (error == nil) else { return }
            
            /// Response 상태 코드 검사
            guard (200..<300).contains((response as? HTTPURLResponse)!.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data: Data = data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            do {
                let decodedData: Apod = try JSONDecoder().decode(Apod.self, from: data)
                completion(.success(decodedData))
            } catch {
                print(error.localizedDescription)
                completion(.failure(NetworkError.decodingFailure))
            }
        }.resume()
    }
}
