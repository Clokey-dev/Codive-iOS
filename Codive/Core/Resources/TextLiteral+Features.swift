//
//  TextLiteral+Features.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation

extension TextLiteral {
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
        static let withdrawButtonLoading = "탈퇴 중..."
        static let withdrawConfirmTitle = "정말 탈퇴하시겠습니까?"
        static let withdrawConfirmMessage = "한 번 탈퇴하면 계정과 모든 데이터는 복구할 수 없습니다."

        // Liked Records
        static let likedRecordsEmpty = "좋아요 한 기록이 없어요!"
        static let likedRecordsEmptyMessage = "마음에 드는 기록을 찾아볼까요?"

        // My Comments
        static let myCommentsEmpty = "아직 남긴 댓글이 없어요!"
        static let myCommentsEmptyMessage = "지금 하나 써볼까요?"

        // Blocked Users
        static let blockedUsersEmpty = "차단한 계정이 없어요"
        static let unblock = "차단 해제"
        static let unblockAlertTitle = "차단 해제"
        static func unblockAlertMessage(_ nickname: String) -> String {
            "\(nickname)님의 차단을 해제하시겠습니까?"
        }

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

        // Errors
        static let loadContextFailure = "신고 대상을 불러오지 못했습니다."
        static let submitFailure = "신고 제출에 실패했습니다. 잠시 후 다시 시도해 주세요."
        static let selectReason = "신고 사유를 선택해 주세요."
        static func detailTooLong(_ limit: Int) -> String {
            "상세 내용은 \(limit)자 이내로 입력해 주세요."
        }

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

    // MARK: - Profile (프로필)
    enum Profile {
        static let loadFailure = "프로필을 불러올 수 없습니다."
        static let followFailure = "팔로우 처리에 실패했습니다."
        static let monthlyHistoryLoadFailure = "월별 기록 조회에 실패했습니다."
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

        // Actions
        static let likeFailure = "좋아요 처리에 실패했습니다."
        static let deleteFailure = "삭제에 실패했습니다."
        static let blockFailure = "차단에 실패했습니다."
        static let invalidUserInfo = "잘못된 사용자 정보입니다."

        // Alerts
        static let deleteAlertTitle = "기록 삭제"
        static let deleteAlertMessage = "이 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다."
        static let blockAlertTitle = "사용자 차단"
        static func blockAlertMessage(_ nickname: String) -> String {
            "\(nickname)님을 차단하시겠습니까?\n차단된 사용자의 기록을 더 이상 볼 수 없습니다."
        }
        static let blockFailureAlertTitle = "차단 실패"

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
