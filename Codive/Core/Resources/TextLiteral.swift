//
//  TextLiteral.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation

enum TextLiteral {
    // MARK: - Common (공통)
    enum Common {
        static let complete = "완료"
        static let cancel = "취소"
        static let save = "저장"
        static let confirm = "확인"
        static let delete = "삭제"
    }
    
    // MARK: - Auth (인증)
    enum Auth {
        // Onboarding
        static let onboardingMainTitle = """
                                         Codive와 함께
                                         스마트한 옷장 관리를
                                         시작해보세요!
                                         """
        static let kakaoLoginButton = "카카오톡으로 시작하기"
        static let appleLoginButton = "애플로 시작하기"
        
        // Terms
        static let termsMainTitle = """
                                     약관에 동의하시면
                                     회원가입이 완료됩니다.
                                     """
        static let termsAgreeAll = "전체 동의"
        static let termsOfService = "(필수) 서비스 이용약관"
        static let privacyPolicy = "(필수) 개인정보 수집/이용 동의"
        static let locationService = "(필수) 위치 기반 서비스 이용약관 동의"
        static let marketingInfo = "(선택) 마케팅 정보 수신 동의"
        static let signUpComplete = "가입 완료"
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
        static let searchAccessibilityLabel = "검색"
        static let notificationAccessibilityLabel = "알림"
    }
    
    // MARK: - Add (추가)
    enum Add {
        static let title = "추가"
        static let question = "추가할 항목은 무엇인가요?"
        
        // Clothes
        static let clothesSectionTitle = "옷 추가"
        static let clothesAiAutoTitle = "AI 자동추가"
        static let clothesAiAutoDescription = "이미지를 업로드하면 옷이 자동으로 등록돼요"
        static let clothesManualTitle = "직접 추가"
        static let clothesManualDescription = "옷을 직접 추가하여 나만의 옷장을 만들어요"
        
        // Record
        static let recordTitle = "기록 추가"
        static let recordDescription = "오늘의 스타일을 기록해요"
        static let recordRecentAlbum = "최근 항목"
        
        // Photo Edit
        static let photoEditTitle = "사진 편집"
        static let photoEditComplete = "편집 완료"
        
        // Record Detail
        static let recordDetailQuestion = "오늘의 내 기록을 추가해볼까요?"
        static let recordDetailStyleTitle = "오늘의 스타일을 선택해보세요"
        static let recordDetailSituationTitle = "어떤 상황에 주로 입으시나요?"
        static let recordDetailCaptionTitle = "캡션을 추가해주세요"
        static let recordDetailCaptionPlaceholder = "나만의 스타일 이야기를 채워보세요.\n#아이템과 #스타일을 자랑해보세요."
        static let recordDetailComplete = "작성 완료"
        
        // Photo Tag
        static let photoTagTitle = "태그하기"
        static let photoTagAnimationText = "오늘 입은 옷을 태그해보세요"
    }
    
    enum Home {
        static let edit = "카테고리 편집"
        static let random = "랜덤 코디"
        static let complete = "코디 완성하기"
        static let codiBoardTitle = "코디 보드"
        static let codiBoardDescription = "옷을 자유롭게 배치하고 확대/축소할 수 있어요."
        static let editCategoryTitle = "카테고리 편집"
        static let reset = "초기화"
        static let apply = "적용하기"
        static let bannerTitle = "오늘 이 코디를 기억하고 싶다면?"
        static let noCodiTitle = "오늘 날씨에 이 코디 어때요?"
        static let decesion = "이 코디로 결정하기"
        static let weatherLoading = "날씨 정보를 가져오는 중입니다..."
        static let failWeather = "날씨 정보를 가져오는 데 실패했습니다."
    }
    
    enum Search {
        static let searchHint = "찾고 싶은 옷이나 브랜드를 검색해보세요"
        static let recentSearch = "최근 검색어"
        static let deleteAll = "전체 삭제"
        static let noTag = "최근 검색어가 없습니다."
        static let recommendedNewsTitle = "님을 위한 추천 소식"
        static let alertTitle = "최근 검색어를 모두 삭제하시겠습니까?"
        static let alertDelete = "삭제"
        static let alertCancel = "취소"
        static let noRestore = "한 번 삭제된 기록은 복구할 수 없습니다."
    }
    
    enum Notification {
        static let title = "알림"
        static let read = "읽음"
        static let notRead = "읽지 않음"
        static let noNewNoti = "새로운 알림이 없습니다."
    }
}
