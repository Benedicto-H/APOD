//
//  APICaller.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

final class NetworkManager {
    
    /// Creational Pattern: `Singleton`
//    static let shared: NetworkManager = NetworkManager()
    
    fileprivate let baseURL: String = "https://api.nasa.gov/planetary/apod"
    fileprivate let apiKey: String = Bundle.main.apiKey
    
//    private init() {}
    
    let session: URLSessionable
    
    /// URLSession을 주입받음.
    /// 테스트 시 MockURLSession을 주입
    init(session: URLSessionable = URLSession.shared) {
        self.session = session
    }
    
    /// `class var` vs `static let(var)`
    /// class var: 클래스 수준의 속성. 즉, 클래스의 모든 인스턴스가 공유될 수 있고 반드시 하나의 인스턴스를 가질 필요가 없음 (Anti-Singleton)
    /// static let(var): Singleton
    class var shared: NetworkManager {
        get {
            return NetworkManager()
        }
    }
    
    func fetchApod<T: Decodable>(dataType: T.Type, completion: @escaping (Result<Apod, NetworkError>) -> Void) -> Void {
        
        guard let url: URL = URL(string: baseURL + "?api_key=\(apiKey)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        
        /// Request의 HTTP 메서드 설정
        request.httpMethod = "GET"
        
        session.dataTask(with: request) { data, response, error in
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
