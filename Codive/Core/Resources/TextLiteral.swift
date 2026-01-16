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
        static let unknown = "알 수 없음"
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
        static let recordPhotoSaveFailure = "사진 저장 실패: "
        
        // Photo Edit
        static let photoEditTitle = "사진 편집"
        static let photoEditComplete = "편집 완료"

        // Exit Alert
        static let exitAlertTitle = "정말 나가시겠습니까?"
        static let exitAlertMessage = "편집 중인 화면은 복구할 수 없습니다"
        static let exitAlertLeave = "나가기"

        // Record Detail
        static let recordDetailQuestion = "오늘의 내 기록을 추가해볼까요?"
        static let recordDetailStyleTitle = "오늘의 스타일을 선택해보세요"
        static let recordDetailSituationTitle = "어떤 상황에 주로 입으시나요?"
        static let recordDetailCaptionTitle = "캡션을 추가해주세요"
        static let recordDetailCaptionPlaceholder = "나만의 스타일 이야기를 채워보세요.\n#아이템과 #스타일을 자랑해보세요."
        static let recordDetailComplete = "작성 완료"

        // Style Options
        static let styleCasual = "캐주얼"
        static let styleLoving = "러블리"
        static let styleMinimal = "미니멀"
        static let styleVintage = "빈티지"
        static let styleSporty = "스포티"
        static let styleStreet = "스트릿"
        static let styleChic = "시크"
        static let styleOffice = "오피스룩"
        static let styleClassic = "클래식"
        static let styleHighteen = "하이틴"

        // Situation Options
        static let situationDate = "데이트"
        static let situationDaily = "데일리"
        static let situationTravel = "여행"
        static let situationExercise = "운동"
        static let situationFestival = "축제"
        static let situationWork = "출근복"
        static let situationParty = "파티"
        
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
        static let todayCodiTitle = "오늘의 코디"
        static let currentCategoryCount = "현재 카테고리"
        static let changeAlertTitle = "변경사항이 있습니다"
        static let changeAlertMessage = "변경사항을 저장하지 않고 나가시겠습니까?"
        static let leave = "나가기"
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
        static let totalCount = "총"
        static let countUnit = "개"
        static let sortAll = "전체"
        static let account = "계정"
        static let hashtag = "해시태그"
    }
    
    enum Notification {
        static let title = "알림"
        static let read = "읽음"
        static let notRead = "읽지 않음"
        static let noNewNoti = "새로운 알림이 없습니다."
        static let feedType = "게시글"
        static let commentType = "댓글"
        static let reportTitle = "신고 접수 안내"
        static func reportBody1(_ target: String) -> String {
            "회원님의 \(target)이 운영 정책 위반으로 신고되었습니다."
        }
        static let reportBody2 = "확인 및 조치는 영업일 기준 3~5일정도 소요됩니다."
    }
    
    enum LookBook {
        static let title = "내 룩북"
        static let addCodiTitle = "코디 추가하기"
        static let makeNewCodi = "새 코디 만들기"
        static let beforeCodi = "이전 코디"
        static let editCodi = "편집하기"
        static let codiNameTitle = "코디 명"
        static let hintCodiNameTitle = "코디 명을 입력하세요"
        static let hintNameTitle = "영화관 데이트"
        static let memoTitle = "개인 메모"
        static let hintMemo = "코디와 관련된 메모를 남겨보세요"
        static let hintMemoTitle = "1주년이니까 오빠가 사준 신발 신고가야됨"
        static let complete = "코디를 완성했어요!"
        static let addLookBookTitle = "룩북 만들기"
        static let hintAddLookBookTitle = "룩북명을 입력해주세요(10자 이내)"
        static let addLookBookButtonTitle = "등록하기"
        static let addCodiCompleteButton = "코디 완성하기"
        static let codiUpload = "코디 업로드"
        static let alertDeleteTitle = "해당 룩북을 삭제하시겠습니까?"
        static let alertDeleteSubTitle = "한 번 삭제된 기록은 복구할 수 없습니다"
        static let loadingTitle = "룩북 로드 중..."
        static let addNewCodi = "새로운 코디 추가하기"
        static let getBeforeCodi = "이전 코디 불러오기"
        static let makeNewCodiDescription1 = "옷을 선택해 새로운 코디를 만들어보세요!"
        static let makeNewCodiDescription2 = "아이템은 최대 10개까지 등록할 수 있어요"
        static let noBeforeCodice = "해당 룩북에 코디가 없습니다."
        static let selectItem = "아이템을 선택해 주세요"
        static let codiDetail = "코디 상세"
        static let codiDelete = "코디 삭제"
        static let editCodiComplete = "수정 완료하기"
        static let exitDescription = "정말 나가시겠습니까?"
        static let noRecovery = "작성중인 내용은 복구할 수 없습니다"
    }

    // MARK: - Setting (설정)
    enum Setting {
        static let title = "설정"

        // Section Titles
        static let loginInfo = "로그인/회원정보"
        static let account = "계정"
        static let notification = "알림"
        static let customerSupport = "고객 지원"

        // Menu Items
        static let likedRecords = "좋아요 한 기록"
        static let myComments = "내가 남긴 댓글"
        static let blockedUsers = "차단한 계정"
        static let pushNotification = "PUSH 알림"
        static let marketingConsent = "마케팅 알림 수신 동의"
        static let versionInfo = "버전 정보"
        static let inquiry = "문의하기"
        static let logout = "로그아웃"
        static let withdraw = "계정 탈퇴"

        // Withdraw
        static let withdrawTitle = "계정 탈퇴"
        static let withdrawNotice = "탈퇴 전 아래 내용을 확인해주세요"
        static let withdrawButton = "계정 탈퇴하기"

        // Liked Records
        static let likedRecordsEmpty = "좋아요 한 기록이 없어요!"
        static let likedRecordsEmptyMessage = "마음에 드는 기록을 찾아볼까요?"

        // My Comments
        static let myCommentsEmpty = "아직 남긴 댓글이 없어요!"
        static let myCommentsEmptyMessage = "지금 하나 써볼까요?"

        // Blocked Users
        static let blockedUsersEmpty = "차단한 계정이 없어요"
        static let unblock = "차단 해제"

        // Common
        static let loadFailed = "불러오지 못했어요"
        static let retry = "다시 시도"
        static let goToFeed = "피드로 이동하기"
    }

    // MARK: - Closet (옷장)
    enum Closet {
        static let clothAddTitle = "옷 추가"
        static let aiRecommendationTitle = "AI가 옷 정보를 불러왔어요"
        static let clothLoadedTitle = "선택하신 옷을 불러왔어요"
        static let noClothInfo = "옷 정보가 없습니다"

        // Form Fields
        static let category = "카테고리"
        static let categoryPlaceholder = "카테고리를 선택하세요"
        static let season = "계절"
        static let seasonPlaceholder = "착용 계절을 선택하세요"
        static let clothName = "옷 이름"
        static let clothNamePlaceholder = "옷 이름을 입력해주세요."
        static let brand = "브랜드"
        static let brandPlaceholder = "브랜드를 입력해주세요."
        static let purchaseUrl = "구매 url"
        static let purchaseUrlPlaceholder = "구매 url을 입력해주세요."

        // Tag Placeholders
        static let brandTag = "브랜드"
        static let productTag = "상품명"
    }

    // MARK: - Report (신고)
    enum Report {
        static let title = "신고하기"
        static let next = "다음"
        static let submit = "신고하기"
        static let complete = "신고가 접수되었습니다."

        // Sections
        static let authorSection = "작성자"
        static let reasonSection = "신고 사유"
        static let selectedReasonSection = "선택된 신고 사유"
        static let detailSection = "문제가 된 부분을 구체적으로 작성해 주세요."
        static let detailPlaceholder = "예시: 욕설을 사용한 특정 문장, 협박성 메시지 등"

        // Reason Details - Violence
        static let violenceDetail1 = "폭력, 학대, 자해, 성매매 등 위험한 행위를 조장"
        static let violenceDetail2 = "불법 행위를 암시하거나 조장하는 게시물 (불법 약물, 도박 등)"

        // Reason Details - Hate Speech
        static let hateDetail1 = "성별, 인종, 종교, 성적 지향 등을 이유로 한 차별적 발언"
        static let hateDetail2 = "혐오, 비하, 폭력 조장 또는 위협적인 표현"

        // Notices
        static let notice1 = "신고 접수 후 패널티 조치까지 영업일 기준 최소 3영업일에서 최대 5영업일 소요될 수 있습니다."
        static let notice2 = "신고가 접수되면 해당 기록이 일시적으로 제한될 수 있으며, 상단의 사유와 함께 검토됩니다."
        static let notice3 = "신고 내용에 대한 사실 확인이 필요할 경우, CloKey 고객센터를 통해 신고자에게 추가적인 자료 제출을 요청할 수 있습니다."
        static let notice4 = "신고가 누적 3회 이상일 경우 계정이 정지되며, 허위 신고가 3회 적발될 경우에도 동일하게 제재가 집행됩니다."
    }

    // MARK: - Feed (피드)
    enum Feed {
        static let detailTitle = "기록 상세"
        static let loadDetailFailed = "Feed를 불러오는데 실패했습니다."
        static let genericLoadFailed = "정보를 불러올 수 없습니다."
        static let dateFormat = "yyyy.M.d"
        static let defaultBrand = "Brand"
        static let defaultProductName = "Product"
        static let likesListLoadFailed = "좋아요 목록을 불러오는데 실패했습니다."

        enum Empty {
            static let noFollowingTitle = "팔로잉한 사람이 아직 없어요."
            static let noFollowingSubtitle = "관심있는 사람을 팔로잉하면\n그들의 스타일을 모아볼 수 있어요."
            static let noFollowingButton = "지금 둘러보기"
            
            static let noFeedsTitle = "관련된 스타일 피드가 아직 없어요."
            static let noFeedsSubtitle = "곧 다양한 코디가\n이 스타일 피드에 올려질 예정이에요!"
            static let noFeedsButton = "다른 스타일 보기"
        }
    }
    
    // MARK: - Comment (댓글)
    enum Comment {
        static let title = "댓글"
        static let placeholder = "댓글 달기"
        static let submit = "등록"
        static let addReply = "답글달기"
        static let hideReplies = "- 답글 숨기기"
        static func repliesCount(_ count: Int) -> String {
            "- 답글 \(count)개 더 보기"
        }
        static let anonymous = "익명"
    }
    
    // MARK: - LikesList (좋아요 목록)
    enum LikesList {
        static let title = "좋아요"
        static let empty = "좋아요를 누른 사람이 없습니다."
        static let anonymous = "익명 사용자"
        static let follow = "팔로우"
        static let following = "팔로잉"
    }
}

extension TextLiteral.Common {
    static let unknownUser = "Unknown User"
}
