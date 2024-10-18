//
//  APICaller.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

import RxSwift

final class APICaller {
    
    /// Creational Pattern: `Singleton`
    static let shared: APICaller = APICaller()
    
    fileprivate let baseURL: String = "https://api.nasa.gov/planetary/apod"
    fileprivate let apiKey: String = Bundle.main.apiKey
    
    private init() {}
    
    func fetchApod(completion: @escaping (Result<Apod, APIError>) -> Void) -> Void {
        
        // MARK: - Quality of Service
        /// ref. https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html
        /// ref. https://unnnyong.com/2020/05/14/ios-thread-queue-gcd-qos/
        DispatchQueue.global(qos: .utility).async {
            guard let url: URL = URL(string: self.baseURL + "?api_key=\(self.apiKey)") else {
                completion(.failure(APIError.invalidURL))
                return
            }
            
            var request: URLRequest = URLRequest(url: url)
            
            /// Request의 HTTP 메서드 설정
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                /// dataTask(with:completionHandler:)의 completionHandler는 Background Thread에서 호출됨
                /// ref. https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory
                /// [Important] The completion handler is called on a different Grand Central Dispatch queue than the one that created the task.
                
                guard (error == nil) else { return }
                
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
                    
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.decodingFailure))
                }
            }.resume()
        }
    }
    
    func fetchApodRx() -> Observable<Apod> {
        /// `Cold Observable` 정의
        /// Observable은 실제로는 시퀀스 정의일뿐,  `Subscribe(구독) 되기 전에는 아무런 이벤트도 내보내지 않음`
        /// (-> 즉, subscribe 되었을 때, 생성됨)
        return Observable.create { observer in
            // MARK: - Subscription here
            guard let url: URL = URL(string: self.baseURL + "?api_key=\(self.apiKey)") else {
                observer.on(.error(APIError.invalidURL))
                return Disposables.create()
            }
            
            var request: URLRequest = URLRequest(url: url)
            
            request.httpMethod = "GET"
            
            let task: URLSessionTask = URLSession.shared.dataTask(with: request) { data, response, error in
                guard (error == nil) else {
                    observer.on(.error(error!))
                    return
                }
                
                guard ((200..<300) ~= (response as? HTTPURLResponse)!.statusCode) else {
                    observer.on(.error(APIError.invalidResponse))
                    return
                }
                
                guard let data: Data = data else {
                    observer.on(.error(APIError.invalidData))
                    return
                }
                
                do {
                    observer.on(.next(try JSONDecoder().decode(Apod.self, from: data)))
                    observer.on(.completed)
                } catch {
                    print(error.localizedDescription)
                    observer.on(.error(APIError.decodingFailure))
                }
            }
            
            task.resume()
            
            /// Observable이 구독 해제될 때, 요청을 취소
            return Disposables.create {
                task.cancel()
                print("********** task가 cancel()됨 **********")
            }
        }
        
        /// `Cold Observable` vs `Hot Observable`
        ///
        /// - `Cold Observable`: Observer가 subscribe 할 때 까지, items를 방출하지 않음
        ///     (-> 즉, Cold Observable을 subscribe하는 Observer는 Observable이 방출하는 items 전체를 subscribe 할 수 있도록 보장 받는다)
        ///
        ///     특징)
        ///     1. Observer가 추가될 때마다, Observable의 실행이 시작됨
        ///     2. 각 Observer는 독립적인 Data Stream을 가짐 (-> 즉, Data Stream 공유 불가능 == Unicast)
        ///
        ///     예시) HTTP 통신, 파일 읽기, Database Query 등
        
        /// -   `Hot Observable`: Observable이 생성되자 마자 items를 방출함
        ///     (-> 즉, Hot Observable을 나중에 subscribe하는 Observer는 subscribe하는 시점의 Observable의 중간부분부터 subscribe 할 수 있음 == 새로운 Observer는 이미 발생한 items에 접근하지 못하고, 이후 발생하는 items만을 받음)
        ///
        ///     특징)
        ///     1. Observer의 subscribe 여부 상관없이 Observable 생성시, items 방출
        ///     2. 여러 Observer들이 같은 Observable을 subscribe하면, 동일한 Data Stream을 가짐 (-> 즉, Data Stream 공유 가능 == Multicast)
        ///
        ///     예시) UIEvent, WebSocket 데이터 스트리밍, Timer 등
    }
}
