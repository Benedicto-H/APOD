//
//  Responsable.swift
//  APOD
//
//  Created by 홍진표 on 11/10/24.
//

import Foundation

//  Endpoint를 생성할 때, 타입을 주입하여 Provider의 request 제네릭에 적용
protocol Responsable {
    associatedtype Response
    
    /**
     `associatedtype`: Protocol 내에서 Generics를 명시하는 방법
     ///    프로토콜을 채택하는 타입에서 구체적인 타입을 지정하도록 강제함
     
     ///    ex.
     protocol Container {
        associatedtype Item
     
        var items: [Item] { get }
        mutating func addItem(_ item: Item)
     }
     
     struct IntContainer: Container {
        var items: [Int] = [Int]()
     
        mutating func addItem(_ item: Int) {
            items.append(item)
        }
     }
     */
}
