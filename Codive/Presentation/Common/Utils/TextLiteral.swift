//
//  TextLiteral.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation

enum TextLiteral {
    
    // MARK: - Auth (인증)
    enum Auth {
        
        // Onboarding (온보딩 화면)
        enum Onboarding {
            static let mainTitle = """
                                   Clokey와 함께
                                   스마트한 옷장 관리를
                                   시작해보세요!
                                   """
            static let kakaoLoginButtonTitle = "카카오톡으로 시작하기"
            static let appleLoginButtonTitle = "애플로 시작하기"
        }
        
        // Terms (약관 동의 화면)
        enum Terms {
            static let mainTitle = """
                                   약관에 동의하시면
                                   회원가입이 완료됩니다.
                                   """
            static let agreeAll = "전체 동의"
            static let termsOfService = "(필수) 서비스 이용약관"
            static let privacyPolicy = "(필수) 개인정보 수집/이용 동의"
            static let locationService = "(필수) 위치 기반 서비스 이용약관 동의"
            static let marketingInfo = "(선택) 마케팅 정보 수신 동의"
            static let signUpCompleteButtonTitle = "가입 완료"
        }
    }
}
