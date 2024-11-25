//
//  MockURLSession.swift
//  APODTests
//
//  Created by 홍진표 on 11/7/24.
//

import Foundation
@testable import APOD

// MARK: - Test Double
/// `Test Double`: 테스트할 때, production object를 대신함
/// Test Double 중에 `Mock`은 호출에 대해 예상하는 결과를 받을 수 있도록 미리 프로그래밍 된 오브젝트
/// ref: http://xunitpatterns.com/Test%20Double.html
/// ret: https://tecoble.techcourse.co.kr/post/2020-09-19-what-is-test-double/
final class MockURLSession: URLSessionable {
    
    /// request 실패를 위한 Flag 변수
    var makeRequestFail: Bool
    var sessionDataTask: MockURLSessionDataTask?
    
    init(makeRequestFail: Bool = false) {
        self.makeRequestFail = makeRequestFail
    }
    
    // MARK: - [Pr] URLSessionable Methods Impl
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        
        let endpoint: Endpoint<Apod> = APIEndpoints.getApod(with: ApodRequestDTO())
        
        /// `성공:` callback으로 넘겨줄 Response
        let successResponse: HTTPURLResponse? = HTTPURLResponse(url: try! endpoint.makeURL(),
                                                                statusCode: 200,
                                                                httpVersion: nil,
                                                                headerFields: nil)
        
        /// `실패:` callback으로 넘겨줄 Response
        let failureResponse: HTTPURLResponse? = HTTPURLResponse(url: try! endpoint.makeURL(),
                                                                statusCode: 400,
                                                                httpVersion: nil,
                                                                headerFields: nil)
        
        let sessionDataTask: MockURLSessionDataTask = MockURLSessionDataTask()
        
        /// override func resume()이 호출되면 completionHandler()가 호출
        sessionDataTask.resumeDidCall = {
            if (self.makeRequestFail) {
                completionHandler(nil, failureResponse, nil)
            } else {
                completionHandler(endpoint.sampleData, successResponse, nil)
            }
        }
        
        self.sessionDataTask = sessionDataTask
        return sessionDataTask
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        
        let endpoint: Endpoint<Apod> = APIEndpoints.getApod(with: ApodRequestDTO())
        
        /// `성공:` callback으로 넘겨줄 Response
        let successResponse: HTTPURLResponse? = HTTPURLResponse(url: try! endpoint.makeURL(),
                                                                statusCode: 200,
                                                                httpVersion: nil,
                                                                headerFields: nil)
        
        /// `실패:` callback으로 넘겨줄 Response
        let failureResponse: HTTPURLResponse? = HTTPURLResponse(url: try! endpoint.makeURL(),
                                                                statusCode: 401,
                                                                httpVersion: nil,
                                                                headerFields: nil)
        
        let sessionDataTask: MockURLSessionDataTask = MockURLSessionDataTask()
        
        /// resume()이 호출되면 completionHandler()가 호출
        sessionDataTask.resumeDidCall = {
            if (self.makeRequestFail) {
                completionHandler(nil, failureResponse, nil)
            } else {
                completionHandler(endpoint.sampleData, successResponse, nil)
            }
        }
        
        self.sessionDataTask = sessionDataTask
        return sessionDataTask
    }
}
