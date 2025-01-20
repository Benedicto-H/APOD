//
//  URLSessionable.swift
//  APOD
//
//  Created by 홍진표 on 11/7/24.
//

import Foundation

// MARK: - Protocol for MOCK/REAL
/// Network Test 시, URLSession의 동작을 모방하기 위한 Protocol
protocol URLSessionable {
    //  URLSession의 dataTask(with:completion:)를 그대로 정의
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask
    func dataTask(with url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask
    
    //  URLSession의 data(for:)를 정의
    /// Convenience method to load data using a URLRequest, creates and resumes a URLSessionDataTask internally.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    
    /**
     `Pr Sendable`: Data Races의 리스크 없이, 임의의 동시 context에서 값을 안전하게 사용할 수 있게 해주는 `Thread-Safe`한 유형의 Protocol
     
     Functions 및 Closures에서는 `@Sendable`로 표시하며, 함수나 클로저가 캡처하는 모든 값은 sendable이어야 한다.
     또한, sendable 클로저는 `값 캡처 (by-value capture)`만을 사용해야 하며, 캡처된 값은 sendable 유형이어야 한다.
     
     ///    ex.
     struct Data: `Sendable`
     class URLResponse: `@unchecked Sendable`
     protocol Error: Sendable
     
     * `@unchecked Sendable`: Sendable의 적합성을 컴파일러가 강제로 검사하지 않으며, 개발자가 해당 타입을 안전하게 사용하도록 책임져야 함.
     
     ///    `Race Condition`: Multi-Threading 환경에서 공유 리소스에 동시에 접근하여 결과가 예측할 수 없게되는 상황
            - 작업의 `순서에 중점`을 두고, 작업을 처리하는 순서가 예기치 못한 결과를 초래할 수 있다는 점에 초점을 맞춤
     
     ///    `Data Races`: Multi-Threading 환경에서 동기화 작업 없이 공유 리소스에 동시에 접근하여 문제가 발생하는 상황
            - `동기화 작업이 없다`는 것은 리소스를 수정하는 과정에서 순서가 보장되지 않음을 뜻함
            - (즉, `순서가 보장되지 않으면 리소스는 안전하게 처리될 수 없음`)
     
            - Data Races의 해결법: `동기화`-> 동기화 작업에는 뮤텍스, 세마포어, 읽기-쓰기 잠금, etc.
            - ('동기화 메커니즘' or 작업 큐와 같은 '작업 처리 방안'을 사용)
     
     ///    `Thread-Safe`: 여러 스레드가 동시에 하나에 자원을 사용할 때, 그 자원이 안전하게 처리될 수 있도록 보장하는 상태
            - (즉, 동기화를 통해 Data Race의 문제를 해결한 것)
     
     ///    `Data Races` ⊂ `Race Condition` (-> Data Races는 Race Condition의 부분집합)
     */
}

// MARK: - Conform the protocol
extension URLSession: URLSessionable { }
