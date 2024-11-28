//
//  APIEndpoints.swift
//  APOD
//
//  Created by 홍진표 on 11/20/24.
//

import Foundation

struct MarsRoversPhotosRequestDTO: Encodable {
    
    let apiKey: String = Bundle.main.apiKey
    let sol: Int = 1000
    let camera: String = "fhaz"
    
    enum CodingKeys: String, CodingKey {
        case sol, camera
        case apiKey = "api_key"
    }
}

//  APIEndpoints를 정의하여 Domain에 종속된 baseURL, path 등을 정의
struct APIEndpoints {
    
    static func getApod(with requestDTO: RequestDTO) -> Endpoint<Apod> {
        return Endpoint(baseURL: "https://api.nasa.gov/",
                        path: "planetary/apod",
                        method: .get,
                        queryParams: requestDTO,
                        sampleData: JSONLoader.getDataFromFileURL(fileName: "MockData")
        )
    }
    
    //  https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=1000&camera=fhaz&api_key=yOU4qZsEdlsu3hSkkL3IyxbcgD1xabLpNNAJMltH
    static func getMarsRoversPhotos(with requestDTO: MarsRoversPhotosRequestDTO) -> Endpoint<MarsRoversPhoto> {
        return Endpoint(baseURL: "https://api.nasa.gov/",
                        path: "mars-photos/api/v1/rovers/curiosity/photos",
                        method: .get,
                        queryParams: requestDTO,
                        sampleData: JSONLoader.getDataFromFileURL(fileName: "PhotoResponseMock")
        )
    }
}
