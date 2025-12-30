//
//  NotificationEntity.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import Foundation

enum RedirectType: String, Codable {
    case member = "MEMBER"
    case history = "HISTORY"
    case weather = "WEATHER"
}

enum ReadStatus: String, Codable {
    case read = "READ"
    case unread = "UNREAD"
}

struct NotificationEntity: Codable, Identifiable {
    let notificationId: Int
    let notificationImageUrl: String?
    let notificationContent: String
    let redirectInfo: String
    let redirectType: RedirectType
    let readStatus: ReadStatus
    let createdAt: String

    var id: Int { notificationId }
}
