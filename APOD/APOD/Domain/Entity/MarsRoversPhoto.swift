//
//  PhotosResponse.swift
//  APOD
//
//  Created by 홍진표 on 11/27/24.
//

import Foundation

struct MarsRoversPhoto: Codable {
    var photos: [Photo]?
    
    struct Photo: Codable {
        
        var id: Int?
        var sol: Int?
        var camera: Camera?
        var imgSrc: String?
        var earthDate: String?
        var rover: Rover?
        
        enum CodingKeys: String, CodingKey {
            case id, sol, camera, rover
            case imgSrc = "img_src"
            case earthDate = "earth_date"
        }
        
        struct Camera: Codable {
            
            var id: Int?
            var name: String?
            var roverID: Int?
            var fullName: String?
            
            enum CodingKeys: String, CodingKey {
                case id, name
                case roverID = "rover_id"
                case fullName = "full_name"
            }
        }
        
        struct Rover: Codable {
            
            var id: Int?
            var name: String?
            var landingDate: String?
            var launchDate: String?
            var status: String?
            var maxSol: Int?
            var maxDate: String?
            var totalPhotos: Int?
            var cameras: [Camera]?
            
            enum CodingKeys: String, CodingKey {
                case id, name, status, cameras
                case landingDate = "landing_date"
                case launchDate = "launch_date"
                case maxSol = "max_sol"
                case maxDate = "max_date"
                case totalPhotos = "total_photos"
            }
            
            struct Camera: Codable {
                var name: String?
                var fullName: String?
                
                enum CodingKeys: String, CodingKey {
                    case name
                    case fullName = "full_name"
                }
            }
        }
    }
}
