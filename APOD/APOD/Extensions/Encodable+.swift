//
//  Encodable+.swift
//  APOD
//
//  Created by 홍진표 on 11/10/24.
//

import Foundation

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        
        let data: Data = try JSONEncoder().encode(self)
        guard let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { throw NSError() }
        
        return dictionary
        
        /**
         `JSONSerialization`: JSON convert to Foundation object (`Deserialize`)     /   Foundation object convert to JSON (`Serialize`)
         // ( Foundation object: `Dictionary`, `Array`, `String`, `Number`, `Bool`, `NSNull`, etc.
         
         `jsonObject(with:options:)`: JSON -> Foundation object (converting)
         */
    }
}
