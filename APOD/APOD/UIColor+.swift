//
//  UIColor+.swift
//  APOD
//
//  Created by 홍진표 on 9/9/24.
//

import Foundation
import UIKit

extension UIColor {
    /// 동적 텍스트 색상
    static let dynamicTextColor: UIColor = {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified: return .black
            case .dark: return .white
            @unknown default: return .black
            }
        }
    }()
}
