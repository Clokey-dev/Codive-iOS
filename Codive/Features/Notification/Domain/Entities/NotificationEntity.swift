//
//  NotificationEntity.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import Foundation

/// 신고 접수 유형
enum ReportType: String, Codable {
    case HISTORY = "HISTORY"
    case COMMENT = "COMMENT"
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
