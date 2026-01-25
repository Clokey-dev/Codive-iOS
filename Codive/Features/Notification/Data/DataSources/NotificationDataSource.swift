//
//  NotificationDataSource.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import Foundation

protocol NotificationDataSourceProtocol {
    func patchEachNotification(notificationId: Int64) async throws
    func patchAllNotification() async throws
    func fetchNotificationList(lastNotificationId: Int64?, size: Int32) async throws -> (content: [NotificationEntity], isLast: Bool)
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO
}

final class NotificationDataSource: NotificationDataSourceProtocol {
    private let apiService: NotificationAPIServiceProtocol
    
    // MARK: - Initializer
    init(
        apiService: NotificationAPIServiceProtocol = NotificationAPIService()
    ) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Methods
    
    /// 알림 읽음 처리
    func patchEachNotification(notificationId: Int64) async throws {
        try await apiService.patchEachNotification(notificationId: notificationId)
    }
    
    /// 알림 전체 읽음 처리
    func patchAllNotification() async throws {
        try await apiService.patchAllNotification()
    }
    
    /// 알림 목록 조회
    func fetchNotificationList(lastNotificationId: Int64?, size: Int32) async throws -> (content: [NotificationEntity], isLast: Bool) {
        let result = try await apiService.fetchNotificationList(
            lastNotificationId: lastNotificationId,
            size: size
        )

        return (
            content: result.content.map { $0.toEntity() },
            isLast: result.isLast
        )
    }
    
    /// 알림 유무
    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO {
        return try await apiService.fetchNotificationExist()
    }
}
