//
//  MarsRoversPhotosResponseDTO.swift
//  APOD
//
//  Created by 홍진표 on 1/23/25.
//

import Foundation

struct MarsRoversPhotoResponseDTO: Decodable {
    
    var photos: [PhotoResponseDTO]?
    
    struct PhotoResponseDTO: Decodable {
        
        var id: Int?
        var sol: Int?
        var camera: CameraResponseDTO?
        var imgSrc: String?
        var earthDate: String?
        var rover: RoverResponseDTO?
        
        enum CodingKeys: String, CodingKey {
            case id, sol, camera, rover
            case imgSrc = "img_src"
            case earthDate = "earth_date"
        }
        
        struct CameraResponseDTO: Decodable {
            
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
        
        struct RoverResponseDTO: Decodable {
            
            var id: Int?
            var name: String?
            var landingDate: String?
            var launchDate: String?
            var status: String?
            var maxSol: Int?
            var maxDate: String?
            var totalPhotos: Int?
            var cameras: [CameraResponseDTO]?
            
            enum CodingKeys: String, CodingKey {
                case id, name, status, cameras
                case landingDate = "landing_date"
                case launchDate = "launch_date"
                case maxSol = "max_sol"
                case maxDate = "max_date"
                case totalPhotos = "total_photos"
            }
            
            struct CameraResponseDTO: Decodable {
                var name: String?
                var fullName: String?
                
                enum CodingKeys: String, CodingKey {
                    case name
                    case fullName = "full_name"
                }
            }
        }
    }
    
    func toDomain() -> MarsRoversPhoto {
        return MarsRoversPhoto(photos: photos?.map({ photoResponseDTO in
            MarsRoversPhoto.Photo(id: photoResponseDTO.id,
                                  sol: photoResponseDTO.sol,
                                  camera: photoResponseDTO.camera.map({ cameraResponseDTO in
                MarsRoversPhoto.Photo.Camera(id: cameraResponseDTO.id,
                                             name: cameraResponseDTO.name,
                                             roverID: cameraResponseDTO.roverID,
                                             fullName: cameraResponseDTO.fullName)}),
                                  
                                  imgSrc: photoResponseDTO.imgSrc,
                                  earthDate: photoResponseDTO.earthDate,
                                  rover: photoResponseDTO.rover.map({ roverResponseDTO in
                MarsRoversPhoto.Photo.Rover(id: roverResponseDTO.id,
                                            name: roverResponseDTO.name,
                                            landingDate: roverResponseDTO.landingDate,
                                            launchDate: roverResponseDTO.launchDate,
                                            status: roverResponseDTO.status,
                                            maxSol: roverResponseDTO.maxSol,
                                            maxDate: roverResponseDTO.maxDate,
                                            totalPhotos: roverResponseDTO.totalPhotos,
                                            
                                            cameras: roverResponseDTO.cameras?.map({ cameraResponseDTO in
                    MarsRoversPhoto.Photo.Rover.Camera(name: cameraResponseDTO.name,
                                                       fullName: cameraResponseDTO.fullName)
                }))
            }))
        }))
    }
}
