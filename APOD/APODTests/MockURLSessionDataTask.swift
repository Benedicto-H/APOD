//
//  MockURLSessionDataTask.swift
//  APODTests
//
//  Created by 홍진표 on 11/7/24.
//

import Foundation
@testable import APOD

/// Network Test 시, 실제 요청을 하지 않고, resume() 호출 시 특정 동작을 실행할 수 있도록 하는 Test class
final class MockURLSessionDataTask: URLSessionDataTask {
    /// [WARNING]: `Class 'MockURLSessionDataTask' must restate inherited '@unchecked Sendable' conformance`
    
    var resumeDidCall: (() -> Void)?
    
    /// [WARNING]: `'init()' was deprecated in iOS 13.0: Please use -[NSURLSession dataTaskWithRequest:] or other NSURLSession methods to create instances`
    init(resumeDidCall: (() -> Void)? = nil) {
        self.resumeDidCall = resumeDidCall
    }
    
    /// resume해도 실제 네트워크 요청이 일어나면 안됨. 단순히 completionHandler 호출용
    override func resume() {
        resumeDidCall?()
    }
}
