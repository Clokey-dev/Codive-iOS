//
//  ReportPopupViewModel.swift
//  Codive
//
//  Created by 한태빈 on 10/14/25.
//

import SwiftUI

// MARK: - 신고 대상 (게시글 / 댓글)
public enum ReportTarget {
    case post
    case comment

    var label: String {
        switch self {
        case .post: return "게시글"
        case .comment: return "댓글"
        }
    }

    var navTitle: String {
        switch self {
        case .post: return "기록 신고하기"
        case .comment: return "댓글 신고하기"
        }
    }

    var contentSectionTitle: String {
        switch self {
        case .post: return "기록 내용"
        case .comment: return "댓글 내용"
        }
    }

    // 대상별 신고 사유 목록
    var reasons: [ReportReason] {
        switch self {
        case .post:
            return ReportReason.postReasons
        case .comment:
            return ReportReason.commentReasons
        }
    }
}

// MARK: - 신고 사유 (대상별로 다른 목록)
enum ReportReason: Hashable {
    // 기록용
    case sexual
    case violence
    case harmful
    case privacy
    case malicious
    case other

    // 댓글용
    case slander
    case discrimination
    case spam
    case infoLeak
    case offensive

    var title: String {
        switch self {
        // 기록용
        case .sexual:       return "음란물 또는 선정적인 내용입니다."
        case .violence:     return "폭력적이거나 불법적인 내용을 포함하고 있습니다."
        case .harmful:      return "청소년에게 유해한 내용입니다."
        case .privacy:      return "개인정보 노출 게시물입니다."
        case .malicious:    return "악의적이거나 불쾌감을 유발하는 표현입니다."
        case .other:        return "기타 (직접 입력 가능)"

        // 댓글용
        case .slander:        return "욕설 및 비방이 포함되어 있습니다."
        case .discrimination: return "혐오 및 차별적 표현입니다."
        case .spam:           return "스팸 홍보 및 도배 댓글입니다."
        case .infoLeak:       return "사적인 정보가 포함된 댓글입니다."
        case .offensive:      return "불쾌감을 주는 표현입니다."
        }
    }

    // 선택 시에만 보이는 보조 설명(더 있어야함 추가 요청할 것)
    var subDescription: [String]? {
        switch self {
        case .violence:
            return [
                "폭력, 학대, 자해, 성매매 등 위험한 행위를 조장",
                "불법 행위를 암시하거나 조장하는 게시물 (불법 약물, 도박 등)"
            ]
        case .discrimination:
            return [
                "성별, 인종, 종교, 성적 지향 등을 이유로 한 차별적 발언",
                "혐오, 비하, 폭력 조장 또는 위협적인 표현"
            ]
        default:
            return nil
        }
    }

    // 기록 신고 전용 목록
    static let postReasons: [ReportReason] = [
        .sexual, .violence, .harmful, .privacy, .malicious, .other
    ]

    // 댓글 신고 전용 목록
    static let commentReasons: [ReportReason] = [
        .slander, .discrimination, .spam, .infoLeak, .offensive, .other
    ]
}
//팝업용 VM
final class ReportPopupViewModel: ObservableObject {
    @Published var target: ReportTarget
    @Published var itemTitle: String
    @Published var reason: String

    init(target: ReportTarget, itemTitle: String, reason: String) {
        self.target = target
        self.itemTitle = itemTitle
        self.reason = reason
    }

    var headerLine1: String { "신고 접수된" }
    var headerLine2: String { "\(target.label)이 있습니다." }

    var middleLine1: String { "신고당한 \(target.label) : \(itemTitle)" }
    var middleLine2: String { "신고 사유 : \(reason)" }
}

// 신고화면용 VM
final class ReportViewModel: ObservableObject {
    @Published var target: ReportTarget
    @Published var selectedReason: ReportReason? = nil
    @Published var customReason: String = ""

    @Published var authorName: String
    @Published var authorId: String
    @Published var contentText: String

    init(target: ReportTarget,
         authorName: String,
         authorId: String,
         contentText: String) {
        self.target = target
        self.authorName = authorName
        self.authorId = authorId
        self.contentText = contentText
    }

    var navTitle: String { target.navTitle }
    var contentSectionTitle: String { target.contentSectionTitle }
    var reasonList: [ReportReason] { target.reasons }

    var isNextEnabled: Bool {
        guard let selected = selectedReason else { return false }
        if selected == .other {
            return !customReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    // 서버 전송용 최종 사유 텍스트
    var submitReasonText: String {
        guard let selected = selectedReason else { return "" }
        return selected == .other ? customReason : selected.title
    }
}
