//
//  NetworkResponseMock.swift
//  APOD
//
//  Created by 홍진표 on 11/21/24.
//

import Foundation

struct NetworkResponseMock {
    
    static let apod: Data = """
{
  "copyright": "George Williams",
  "date": "2024-11-07",
  "explanation": "This spectacular intergalactic skyscape features Arp 227, a curious system of galaxies from the 1966 Atlas of Peculiar Galaxies. Some 100 million light-years distant within the boundaries of the constellation Pisces, Arp 227 consists of the two galaxies prominent above and left of center, the shell galaxy NGC 474 and its blue, spiral-armed neighbor NGC 470. The readily apparent shells and star streams of NGC 474 are likely tidal features originating from the accretion of another smaller galaxy during close gravitational encounters that began over a billion years ago. The large galaxy on the bottom righthand side of the deep image, NGC 467, appears to be surrounded by faint shells and streams too, evidence of another merging galaxy system. Intriguing background galaxies are scattered around the field that also includes spiky foreground stars. Of course, those stars lie well within our own Milky Way Galaxy. The telescopic field of view spans 25 arc minutes or just under 1/2 degree on the sky.",
  "hdurl": "https://apod.nasa.gov/apod/image/2411/NGC474_S1_Crop.jpg",
  "media_type": "image",
  "service_version": "v1",
  "title": "Shell Galaxies in Pisces",
  "url": "https://apod.nasa.gov/apod/image/2411/NGC474_S1_Crop1024.jpg"
}
""".data(using: .utf8)!
}
