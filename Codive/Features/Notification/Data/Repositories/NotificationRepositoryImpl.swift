//
//  NotificationRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

final class NotificationRepositoryImpl: NotificationRepository {
    // MARK: - Properties
    private let datasource: NotificationDataSource
    
    // MARK: - Initializer
    init(datasource: NotificationDataSource) {
        self.datasource = datasource
    }
    
    // MARK: - Methods
    func fetchNotifications() -> [NotificationEntity] {
        return datasource.fetchNotifications()
    }
    
    func fetchReportStatus() -> ReportEntity {
        return datasource.fetchReportStatus()
    }
    
    func markNotificationAsRead(request: NotificationReadRequestEntity) async throws {
        try await datasource.patchNotificationRead(notificationId: request.notificationId)
    }
}
