//
//  Observable.swift
//  APOD
//
//  Created by 홍진표 on 9/17/24.
//

import Foundation

// MARK: - Custom Observable
/// Generic 타입 T를 통해 어떠한 데이터 타입도 저장 되도록 함
final class CustomObservable<T> {
    
    // MARK: - Properties
    /// Behavioral Pattern: `Observer`
    var value: T {
        didSet {
            /// listener를 통해 새로운 값을 전달
            listener?(value)
        }
    }
    
    private var listener: ((T) -> Void)?
    
    // MARK: - Methods
    init(_ value: T) {
        self.value = value
    }
    
    /// 외부에서 전달된 closure를 listener로 설정
    func bind(_ closure: @escaping ((T) -> Void)) -> Void {
        
        closure(value)
        listener = closure
    }
}
