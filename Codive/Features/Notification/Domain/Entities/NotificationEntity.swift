//
//  NotificationEntity.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import Foundation

/// 알림 유형
enum RedirectType: String, Codable {
    case member = "MEMBER"
    case history = "HISTORY"
    case weather = "WEATHER"
}

/// 알림 읽음/읽지 않음 유형
enum ReadStatus: String, Codable {
    case read = "READ"
    case unread = "UNREAD"
}

/// 알림 목록 조회 api
struct NotificationEntity: Codable, Identifiable {
    let notificationId: Int
    let notificationImageUrl: String?
    let notificationContent: String
    let redirectInfo: String
    let redirectType: RedirectType
    var readStatus: ReadStatus
    let createdAt: String

    var id: Int { notificationId }
}

/// 신고 접수 유형
enum ReportType: String, Codable {
    case feed = "FEED"
    case comment = "COMMENT"
}

/// 신고 접수 안내 api
struct ReportEntity: Codable {
    let isReported: Bool
    let reportType: ReportType? 
}

/// 알림 읽음 처리 request api
struct NotificationReadRequestEntity: Codable {
    let notificationId: Int
}
