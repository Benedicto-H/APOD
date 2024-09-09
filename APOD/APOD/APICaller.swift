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
    
    let baseURL: String = "https://api.nasa.gov/planetary/apod"
    let apiKey: String = Bundle.main.apiKey
    
    private init() {}
    /*
    func fetchAPODs() async throws -> Apod? {
        
        guard let url: URL = URL(string: baseURL + "?api_key=\(apiKey!)") else { throw URLError(.badURL) }
        
        do {
            /// Swift Concurrency를 통해 Data, Response를 asynchronous 처리
            let (data, response): (Data, URLResponse) = try await URLSession.shared.data(from: url)
            
            /// Response 상태 코드 검사
            guard (200 ..< 300).contains((response as? HTTPURLResponse)!.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            return try JSONDecoder().decode(Apod.self, from: data)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
     */
    
    func fetchApod(completion: @escaping (Result<Apod, APIError>) -> Void) -> Void {
        
        guard let url: URL = URL(string: baseURL + "?api_key=\(apiKey)") else {
            completion(.failure(APIError.invalidURL("Invalid URL")))
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        
        /// Request의 HTTP 메서드 설정
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            /// Response 상태 코드 검사
            guard (200..<300).contains((response as? HTTPURLResponse)!.statusCode) else {
                completion(.failure(APIError.invalidResponse("Invalid Response")))
                return
            }
            
            guard let data: Data = data else {
                completion(.failure(.invalidData("Invalid Data")))
                return
            }
            
            do {
                let decodedData: Apod = try JSONDecoder().decode(Apod.self, from: data)
                completion(.success(decodedData))
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}
