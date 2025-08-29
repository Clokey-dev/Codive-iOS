//
//  Font+Extensions.swift
//  Clokey
//
//  Created by 황상환 on 8/29/25.
//

import SwiftUI

public extension Font {
    // MARK: - Title

    /// semibold 20
    static let clokey_title1 = customPretendard(size: 20, weight: .semiBold)
    
    /// semibold 18
    static let clokey_title2 = customPretendard(size: 18, weight: .semiBold)
    
    /// medium 18
    static let clokey_title3 = customPretendard(size: 18, weight: .medium)

    // MARK: - Body
    
    /// medium 16
    static let clokey_body1_medium = customPretendard(size: 16, weight: .medium)
    
    /// regular 16
    static let clokey_body1_regular = customPretendard(size: 16, weight: .regular)
    
    /// medium 14
    static let clokey_body2_medium = customPretendard(size: 14, weight: .medium)
    
    /// regular 14
    static let clokey_body2_regular = customPretendard(size: 14, weight: .regular)
    
    /// medium 12
    static let clokey_body3_medium = customPretendard(size: 12, weight: .medium)
    
    /// regular 12
    static let clokey_body3_regular = customPretendard(size: 12, weight: .regular)
    
    /// regular 10
    static let clokey_body4_regular = customPretendard(size: 10, weight: .regular)
    
    /// Pretendard 폰트를 쉽게 사용하기 위한 private 함수
    private static func customPretendard(size: CGFloat, weight: PretendardWeight) -> Font {
        return .custom(weight.name, size: size)
    }
}

private enum PretendardWeight {
    case black
    case bold
    case extraBold
    case extraLight
    case light
    case medium
    case regular
    case semiBold
    case thin
    
    var name: String {
        switch self {
        case .black:
            return "Pretendard-Black"
        case .bold:
            return "Pretendard-Bold"
        case .extraBold:
            return "Pretendard-ExtraBold"
        case .extraLight:
            return "Pretendard-ExtraLight"
        case .light:
            return "Pretendard-Light"
        case .medium:
            return "Pretendard-Medium"
        case .regular:
            return "Pretendard-Regular"
        case .semiBold:
            return "Pretendard-SemiBold"
        case .thin:
            return "Pretendard-Thin"
        }
    }
}
