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
    var sut: NetworkManager?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        /// `setUpWithError()`: 각각의 test case가 실행되기 전마다 호출되어 각 테스트가 모두 같은 상태와 조건에서 실행될 수 있도록 만들어 줄 수 있는 메서드
        try super.setUpWithError()
        sut = .init(session: MockURLSession())
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
    
    func test_fetchApod호출시_statusCode가200일때() -> Void {
        
        //  Given
        let expectation: XCTestExpectation = XCTestExpectation()
        guard let data = JSONLoader.getDataFromFileURL(fileName: "MockAPOD"),
              let response = try? JSONDecoder().decode(Apod.self, from: data) else {
            print("Mock Data 없음")
            return
        }
        
        //  When
        sut?.fetchApod (dataType: Apod.self) { result in
            switch result {
            case .success(let apod):
                
                //  Then
                print("***** 테스트 성공 *****")
                XCTAssertEqual(apod.title, response.title)
                XCTAssertEqual(apod.explanation, response.explanation)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_fetchApod호출시_statusCode가200이아닐때() -> Void {
        
        //  Given
        sut = .init(session: MockURLSession(makeRequestFail: true))
        let expectation: XCTestExpectation = XCTestExpectation()
        
        //  When
        sut?.fetchApod (dataType: Apod.self) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                
                //  Then
                print("***** 테스트 실패 *****")
                XCTAssertEqual(error.localizedDescription, NetworkError.invalidResponse.localizedDescription)
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
