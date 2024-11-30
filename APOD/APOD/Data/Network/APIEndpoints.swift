//
//  APIEndpoints.swift
//  APOD
//
//  Created by 홍진표 on 11/20/24.
//

import Foundation

//  APIEndpoints를 정의하여 Domain에 종속된 baseURL, path 등을 정의
struct APIEndpoints {
    
    static func getApod(with request: APIKeyProvider) -> Endpoint<Apod> {
        
        return Endpoint(baseURL: "https://api.nasa.gov/",
                        path: "planetary/apod",
                        method: .get,
                        queryParams: request,
                        sampleData: JSONLoader.getDataFromFileURL(fileName: "MockData")
        )
    }
    
    static func getMarsRoversPhotos(with request: APIKeyProvider) -> Endpoint<MarsRoversPhoto> {
        return Endpoint(baseURL: "https://api.nasa.gov/",
                        path: "mars-photos/api/v1/rovers/curiosity/photos",
                        method: .get,
                        queryParams: request,
                        sampleData: JSONLoader.getDataFromFileURL(fileName: "PhotoResponseMock")
        )
    }
}
