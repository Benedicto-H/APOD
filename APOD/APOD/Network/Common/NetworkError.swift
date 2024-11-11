//
//  APIError.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation

// MARK: - 사용자 정의 API Error 타입
enum NetworkError: LocalizedError {
    
    case unknownError
//    case httpStatusError(HTTPStatusError)
    case serverError(ServerError)
    case componentsError
    case urlRequestError(Error)
    case parsingError(Error)
    case emptyData
    case decodingError
    case toDictionaryError
    
    var errorDescription: String? {
        switch self {
        case .unknownError: return "알 수 없는 에러입니다."
//        case .httpStatusError(let httpStatusError):
//            switch httpStatusError {
//            case .clientError(let clientError): return "Client 에러입니다. \n[CODE]: \(clientError.rawValue)."
//            case .serverError(let serverError): return "Server 에러입니다. \n[CODE]: \(serverError.rawValue)."
//            }
        case .serverError(let serverError): return "Status 코드 에러입니다. \(serverError) Code: \(serverError.rawValue)"
        case .componentsError: return "components 생성 에러가 발생했습니다."
        case .urlRequestError: return "URL Request 관련 에러가 발생했습니다."
        case .parsingError: return "데이터 Parsing 중 에러가 발생했습니다."
        case .emptyData: return "Data가 비어있습니다."
        case .decodingError: return "Decoding 에러가 발생했습니다."
        case .toDictionaryError: return "JSON convert to Foundation object 에러가 발생했습니다."
        }
    }
}

// MARK: - HTTP 상태 에러 정의
enum HTTPStatusError {
    case clientError(ClientError)
    case serverError(ServerError)
    
    enum ClientError: Int {
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
    }

    enum ServerError: Int {
        case internalServerError = 500
        case notImplemented = 501
        case serviceUnavailable = 503
    }
}

enum ServerError: Int {
    case unknown
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case unsplashError = 500
    case unsplashError2 = 503
}

