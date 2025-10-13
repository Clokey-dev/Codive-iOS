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
                                   Codive와 함께
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
    
    // MARK: - TabBar (탭바)
    enum TabBar {
        static let home = "홈"
        static let closet = "옷장"
        static let add = ""
        static let feed = "피드"
        static let profile = "마이페이지"
    }
    
    // MARK: - Navigation (상단 네비게이션)
    enum Navigation {
        static let logoPlaceholder = "Logo"
        static let searchButtonAccessibilityLabel = "검색"
        static let notificationButtonAccessibilityLabel = "알림"
    }
    
    // MARK: - Add (옷/이미지 추가)
    enum Add {
        static let mainTitle = "추가"
        static let questionTitle = "추가할 항목은 무엇인가요?"
        
        // 옷 추가 섹션
        static let clothesSectionTitle = "옷 추가"
        static let aiAutoAddTitle = "AI 자동추가"
        static let aiAutoAddDescription = "이미지를 업로드하면 옷이 자동으로 등록돼요"
        static let manualAddTitle = "직접 추가"
        static let manualAddDescription = "옷을 직접 추가하여 나만의 옷장을 만들어요"
        
        // 기록 추가 섹션
        static let recordSectionTitle = "기록 추가"
        static let recordAddTitle = "기록 추가"
        static let recordAddDescription = "오늘의 스타일을 기록해요"
        
        // 기록 추가 화면
        static let recordAddNavigationTitle = "기록 추가"
        static let completeButtonTitle = "완료"
        static let recentAlbumTitle = "최근 항목"
    }
}
