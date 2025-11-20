//
//  NotificationEntity.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import Foundation

struct NotificationEntity: Identifiable {
    let id: Int
    let imageUrl: String?
    let message: String
    let isRead: Bool
}
