//
//  NotificationRepository.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

protocol NotificationRepository {
    func patchEachNotification(notificationId: Int64) async throws
    func patchAllNotification() async throws
    func fetchNotificationList(lastNotificationId: Int64?, size: Int32) async throws -> (content: [NotificationEntity], isLast: Bool)
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO
}
