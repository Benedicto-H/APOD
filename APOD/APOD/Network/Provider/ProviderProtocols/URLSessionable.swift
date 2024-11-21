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
    //  URLSession의 dataTask(with:completion:)을 그대로 정의
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask
//    func dataTask(with url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask
    
    /// `Pr Sendable`은 Multi-Threading 환경에서 동기화 작업 없이 공유 리소스에 동시에 접근하여 문제가 발생하는 상황인 `Data Races`의 리스크 없이,
    /// 임의의 동시 context에서 값을 안전하게 사용할 수 있게 해주는 `Threaad-Safe`한 유형의 Protocol
    ///
    /// Functions 및 Closures 에서는 `@Sendable`로 표시하며, 함수나 클로저가 캡처하는 모든 값은 sendable이어야 한다.
    /// 또한, sendable 클로저는 `값 캡처 (by-value capture)`만을 사용해야 하며, 캡처된 값은 sendable 유형이어야 한다.
    ///
    /// `struct Data: Sendable`
    /// `class URLResponse: @unchecked Sendable`    //  `@unchecked Sendable`: Sendable의 적합성을 컴파일러가 강제로 검사하지 않으며, 개발자가 해당 타입을 안전하게 사용하도록 책임져야 함
    /// `protocol Error: Sendable`
}

// MARK: - Conform the protocol
extension URLSession: URLSessionable { }
