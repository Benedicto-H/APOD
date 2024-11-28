//
//  APODTests.swift
//  APODTests
//
//  Created by 홍진표 on 11/7/24.
//

import XCTest
@testable import APOD

final class APODTests: XCTestCase {

    /// sut: System Under Test (즉, test를 할 타입)
    var sut: Provider?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        /// `setUpWithError()`: 각각의 test case가 실행되기 전마다 호출되어 각 테스트가 모두 같은 상태와 조건에서 실행될 수 있도록 만들어 줄 수 있는 메서드
        try super.setUpWithError()
        
        // MARK: - URLSessionProtocol을 활용한 경우
        /// Mock 데이터 주입
//        sut = APIProvider(session: MockURLSession())
        
        // MARK: - URLProtocol을 활용한 경우
        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        let urlSession: URLSession = URLSession(configuration: configuration)
        
        sut = APIProvider(session: urlSession)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        /// `tearDownWithError`: 각각의 test 실행이 끝난 후마다 호출되는 메서드, 보통 setUpWithError()에서 설정한 값들을 해제할 때 사용됨
        try super.tearDownWithError()
        sut = nil
    }
    
    // MARK: - 테스트는 `기대하는 값과 결괏값을 비교하는 과정`으로 이루어짐
    /// given/ when/ then으로 나누어 작성하는 이유..
    /// 이러한 흐름의 테스트 작성 방법은 BDD(Behavior Driven Development)라는 테스트 방식에서 가져온 것.
    /// BDD는 시나리오를 설정하여 예상대로 결과가 나타나는지를 확인하는 방법론으로,
    /// - 어떤 상황이 주어지고(`given`):  시나리오상의 예정된 행위(behavior)를 하기 전에 조건 등을 설정
    /// - 어떤 코드를 실행하고(`when`):  예정된 행위(behavior)를 수행
    /// - 테스트 결과를 확인하는(`then`):  예정된 행위로 인해 예상한 결과를 도출하는지를 확인
    /// 단계로 구분하여 테스트의 흐름을 보다 쉽게 파악할 수 있음
    
    func test_getMarsRoversPhotos_when_Success() throws -> Void {
        
        //  Given
        let expectation: XCTestExpectation = XCTestExpectation()
        let endpoint: Endpoint<MarsRoversPhoto> = APIEndpoints.getMarsRoversPhotos(with: MarsRoversPhotosRequestDTO())
        
        guard let data: Data = JSONLoader.getDataFromFileURL(fileName: "PhotoResponseMock"),
              let response: MarsRoversPhoto = try? JSONDecoder().decode(MarsRoversPhoto.self, from: data) else {
            throw NetworkError.emptyData
        }
        
        MockURLProtocol.requestHandler = { request in
            /// `성공:` callback으로 넘겨줄 Response
            let successResponse: HTTPURLResponse? = HTTPURLResponse(url: try! endpoint.makeURL(),
                                                                    statusCode: 200,
                                                                    httpVersion: nil,
                                                                    headerFields: nil)
            
            return (endpoint.sampleData, successResponse, nil)
        }
        
        //  When
        sut?.request(with: endpoint) { result in
            switch result {
            case .success(let marsRoversPhotoResponse):
                //  Then
                print("***** 테스트 성공 *****")
                print("marsRoversPhotoResponse: \(marsRoversPhotoResponse)")
                XCTAssertEqual(marsRoversPhotoResponse.photos?.first?.id, response.photos?.first?.id)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_request호출시_statusCode가200일때() throws -> Void {
        
        //  Given
        let expectation: XCTestExpectation = XCTestExpectation()
        let endpoint: Endpoint<Apod> = APIEndpoints.getApod(with: RequestDTO())
        
        guard let data: Data = JSONLoader.getDataFromFileURL(fileName: "MockData"),
              let response: Apod = try? JSONDecoder().decode(Apod.self, from: data) else {
            throw NetworkError.emptyData
        }
        
        MockURLProtocol.requestHandler = { request in
            /// `성공:` callback으로 넘겨줄 Response
            let successResponse: HTTPURLResponse? = HTTPURLResponse(url: try! endpoint.makeURL(),
                                                                    statusCode: 200,
                                                                    httpVersion: nil,
                                                                    headerFields: nil)
            
            return (endpoint.sampleData, successResponse, nil)
        }
        
        //  When
        sut?.request(with: endpoint) { result in
            switch result {
            case .success(let apodResponse):
                //  Then
                print("***** 테스트 성공 *****")
                print("apodResponse: \(apodResponse)")
                XCTAssertEqual(apodResponse.title, response.title)
                XCTAssertEqual(apodResponse.explanation, response.explanation)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_request호출시_statusCode가400일때() -> Void {
        
        //  Given
//        sut = APIProvider(session: MockURLSession(makeRequestFail: true))
        
        let expectation: XCTestExpectation = XCTestExpectation()
        let endpoint: Endpoint<Apod> = APIEndpoints.getApod(with: RequestDTO())
        
        MockURLProtocol.requestHandler = { request in
            /// `실패:` callback으로 넘겨줄 Response
            let failureResponse: HTTPURLResponse? = HTTPURLResponse(url: try! endpoint.makeURL(),
                                                                    statusCode: 400,
                                                                    httpVersion: nil,
                                                                    headerFields: nil)
            
            return (nil, failureResponse, nil)
        }
        
        //  When
        sut?.request(with: endpoint) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                //  Then
                print("***** 테스트 실패 *****")
                print("error: \(error.localizedDescription)")
                XCTAssertEqual(error.localizedDescription, NetworkError.HTTPStatusError.ClientError.badRequest.errorDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        /// test로 시작하는 메서드들은 작성해야 할 test case가 되는 메서드
        /// 메서드 네이밍의 시작은 무조건 test로 시작되어야 함
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        /// 성능을 테스트해보기 위한 메서드
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
