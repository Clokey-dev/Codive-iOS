//
//  ReportEntity.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import Foundation

// MARK: - Typealiases
public typealias UserID = Int
public typealias PostID = Int
public typealias CommentID = Int

// MARK: - 신고 대상
public enum ReportTarget: Identifiable, Equatable, Hashable, Sendable, Codable {
    case post(id: PostID)
    case comment(id: CommentID)

    public var id: String {
        switch self {
        case .post(let id): "post:\(id)"
        case .comment(let id): "comment:\(id)"
        }
    }
}

// 작성자 표시용 스냅샷
public struct AuthorSnapshot: Sendable, Equatable, Hashable {
    public let userId: UserID
    public let nickname: String
    public let handle: String
    public let avatarURL: URL?

    public init(userId: UserID, nickname: String, handle: String, avatarURL: URL?) {
        self.userId = userId
        self.nickname = nickname
        self.handle = handle
        self.avatarURL = avatarURL
    }
}

// 신고 화면에 필요한 최소 표시 정보
public struct ReportContext: Sendable, Equatable {
    public let target: ReportTarget
    public let author: AuthorSnapshot
    public let previewText: String

    public init(target: ReportTarget,
                author: AuthorSnapshot,
                previewText: String) {
        self.target = target
        self.author = author
        self.previewText = previewText
    }
}

// MARK: - 게시글 신고 사유
public enum PostReportReason: Int, CaseIterable, Codable, Sendable {
    case sexual
    case violence
    case harmful
    case privacy
    case hate
    case etc

    public var title: String {
        switch self {
        case .sexual:   "선정적·음란한 콘텐츠"
        case .violence: "폭력 또는 불법 정보"
        case .harmful:  "청소년에게 유해한 내용"
        case .privacy:  "개인정보 침해"
        case .hate:     "악의적이거나 불쾌감을 유발"
        case .etc:      "기타"
        }
    }
}

// MARK: - 댓글 신고 사유
public enum CommentReportReason: Int, CaseIterable, Codable, Sendable {
    case abuse
    case discrim
    case spam
    case privacy
    case hate
    case etc

    public var title: String {
        switch self {
        case .abuse:    "욕설 또는 비방"
        case .discrim:  "혐오·차별적 표현"
        case .spam:     "스팸·광고 또는 도배"
        case .privacy:  "사적인 정보 공개"
        case .hate:     "악의적이거나 불쾌감을 유발"
        case .etc:      "기타"
        }
    }
}

// MARK: - 통합 신고 사유
public enum ReportReason: Equatable, Hashable, Codable, Sendable {
    case post(PostReportReason)
    case comment(CommentReportReason)

    public var isEtc: Bool {
        switch self {
        case .post(let r):    return r == .etc
        case .comment(let r): return r == .etc
        }
    }

    public var title: String {
        switch self {
        case .post(let r):    return r.title
        case .comment(let r): return r.title
        }
    }
}

// MARK: - 도메인 검증 결과
public struct ReportValidation: Equatable, Sendable {
    public let isValid: Bool
    public let failure: Failure?

    public enum Failure: Equatable, Sendable {
        case missingReason
        case detailRequiredForEtc
        case detailTooLong(limit: Int)
    }

    public static let valid = ReportValidation(isValid: true, failure: nil)
    public static func invalid(_ f: Failure) -> ReportValidation {
        .init(isValid: false, failure: f)
    }
}

// MARK: - 신고 작성 초안 엔티티
public struct ReportDraft: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let target: ReportTarget
    public private(set) var selectedReason: ReportReason?
    public private(set) var detail: String = ""

    public static let maxDetailLength = 500

    public init(target: ReportTarget) {
        self.target = target
        self.id = "draft:\(target.id)"
    }

    public mutating func select(_ reason: ReportReason) {
        selectedReason = reason
        if !reason.isEtc { detail = "" }
    }

    public mutating func updateDetail(_ text: String) {
        detail = String(text.prefix(Self.maxDetailLength))
    }

    // 순수 규칙 평가 결과만 반환
    public func validate() -> ReportValidation {
        guard let reason = selectedReason else {
            return .invalid(.missingReason)
        }
        if reason.isEtc && detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .invalid(.detailRequiredForEtc)
        }
        if detail.count > Self.maxDetailLength {
            return .invalid(.detailTooLong(limit: Self.maxDetailLength))
        }
        return .valid
    }
}

// MARK: - 최종 신고 엔티티
public struct Report: Identifiable, Equatable, Hashable, Codable, Sendable {
    public let id: String           
    public let target: ReportTarget
    public let reason: ReportReason
    public let detail: String?
    public let reporterId: UserID
    public let createdAt: Date

    public init(target: ReportTarget,
                reason: ReportReason,
                detail: String?,
                reporterId: UserID,
                createdAt: Date = Date()) {
        self.target = target
        self.reason = reason
        self.detail = detail?.nilIfBlank()
        self.reporterId = reporterId
        self.createdAt = createdAt
        self.id = "report:\(target.id):\(Int(createdAt.timeIntervalSince1970))"
    }
}

public enum ReportError: Error, Equatable, Sendable {
    case invalidDraft(ReportValidation.Failure)
}

// MARK: - 신고사유 nil 확인
private extension String {
    func nilIfBlank() -> String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}

// Draft → Report 변환 extension
public extension ReportDraft {
    func build(reporterId: UserID, now: Date = Date()) throws -> Report {
        let v = validate()
        guard v.isValid else {
            throw ReportError.invalidDraft(v.failure!)
        }
        return Report(
            target: target,
            reason: selectedReason!,
            detail: detail,
            reporterId: reporterId,
            createdAt: now
        )
    }
}
