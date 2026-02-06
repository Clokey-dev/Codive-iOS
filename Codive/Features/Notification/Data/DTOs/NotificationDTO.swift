//
//  NotificationDTO.swift
//  Codive
//
//  Created by 한금준 on 1/24/26.
//

import Foundation

enum NotificationType: String {
    case follow = "FOLLOW"
    case followRequest = "FOLLOW_REQUEST"
    case comment = "COMMENT"
    case reply = "REPLY"
    case like = "LIKE"
    case temperatureDaily = "TEMPERATURE_DAILY"
    case unknown = "UNKNOWN"
}

enum ReadStatus: String {
    case read = "READ"
    case notRead = "NOT_READ"
}

enum NotificationRedirectType: String {
    case none = "NONE"
    case historyRedirect = "HISTORY_REDIRECT"
    case memberRedirect = "MEMBER_REDIRECT"
}

// MARK: - DTO

/// 알림 목록 조회
struct NotificationListResponseDTO {
    let content: [NotificationListResponseItem]
    let isLast: Bool
}

struct NotificationActionDTO {
    let redirectType: NotificationRedirectType
    let redirectInfo: String
}

struct NotificationListResponseItem {
    let notificationId: Int64
    let notificationImageUrl: String
    let notificationContent: String
    let notificationType: NotificationType
    let action: NotificationActionDTO
    let readStatus: ReadStatus
    let createdAt: String
}

struct NotificationExistAPIResponseDTO {
    let existsUnreadNotification: Bool
}

struct ReportReceivedAPIResponseDTO {
    let isReported: Bool
    let targetType: ReportType?
}
