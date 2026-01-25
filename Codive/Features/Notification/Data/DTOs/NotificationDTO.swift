//
//  NotificationDTO.swift
//  Codive
//
//  Created by 한금준 on 1/24/26.
//

import Foundation

/// 알림 목록 조회
struct NotificationListResponseDTO {
    let content: [NotificationListResponseItem]
    let isLast: Bool
}

struct NotificationListResponseItem {
    let notificationId: Int64
    let notificationImageUrl: String
    let notificationContent: String
    let redirectInfo: String
    let redirectType: String
    let readStatus: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case notificationId
        case notificationImageUrl
        case notificationContent
        case redirectInfo
        case redirectType
        case readStatus
        case createdAt
    }
    
    private func parseDate(_ dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter.date(from: dateString) ?? Date()
    }
    
    func toEntity() -> NotificationEntity {
        return NotificationEntity(
            notificationId: notificationId,
            notificationImageUrl: notificationImageUrl,
            notificationContent: notificationContent,
            redirectInfo: redirectInfo,
            redirectType: RedirectType(rawValue: redirectType) ?? .member,
            readStatus: ReadStatus(rawValue: readStatus) ?? .unread,
            createdAt: createdAt
        )
    }
}

struct NotificationExistAPIResponseDTO {
    let existsUnreadNotification: Bool
}
