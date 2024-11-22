//
//  APIEndpoints.swift
//  APOD
//
//  Created by 홍진표 on 11/20/24.
//

import Foundation

struct APIEndpoints {
    
    static func getApod(with apodRequest: ApodRequestDTO) -> Endpoint<Apod> {
        return Endpoint(baseURL: "https://api.nasa.gov/",
                        path: "planetary/apod",
                        method: .get,
                        queryParams: apodRequest,
                        sampleData: JSONLoader.getDataFromFileURL(fileName: "MockData")
        )
    }
}
