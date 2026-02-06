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
    func patchEachNotification(notificationId: Int64) async throws {
        try await datasource.patchEachNotification(notificationId: notificationId)
    }
    
    func patchAllNotification() async throws {
        try await datasource.patchAllNotification()
    }
    
    func fetchNotificationList(
        lastNotificationId: Int64?,
        size: Int32
    ) async throws -> NotificationListResponseDTO {
        return try await datasource.fetchNotificationList(
            lastNotificationId: lastNotificationId,
            size: size
        )
    }
    
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO {
        return try await datasource.fetchNotificationExist()
    }
    
    func fetchReportReceived() async throws -> ReportReceivedAPIResponseDTO {
        return try await datasource.fetchReportReceived()
    }
}
