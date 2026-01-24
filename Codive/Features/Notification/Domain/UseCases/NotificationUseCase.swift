//
//  NotificationUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

final class NotificationUseCase {
    // MARK: - Properties
    private let repository: NotificationRepository
    
    // MARK: - Initializer
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    // MARK: - Methods
    func patchEachNotification(notificationId: Int64) async throws{
        try await repository.patchEachNotification(notificationId: notificationId)
    }
    
    func patchAllNotification() async throws {
        try await repository.patchAllNotification()
    }
    
    func fetchNotificationList(lastNotificationId: Int64?, size: Int32) async throws -> (content: [NotificationEntity], isLast: Bool) {
        return try await repository.fetchNotificationList(
            lastNotificationId: lastNotificationId,
            size: size
        )
    }
    
//    func fetchReportStatus() -> ReportEntity {
//        return false
//    }
    
    func markNotificationAsRead(notificationId: Int64) async throws {
//        let request = NotificationReadRequestEntity(notificationId: notificationId)
//        try await repository.markNotificationAsRead(request: request)
    }
}
