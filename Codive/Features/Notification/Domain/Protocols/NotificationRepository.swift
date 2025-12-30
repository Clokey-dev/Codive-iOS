//
//  NotificationRepository.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

protocol NotificationRepository {
    func fetchNotifications() -> [NotificationEntity]
    func fetchReportStatus() -> ReportEntity
    func markNotificationAsRead(request: NotificationReadRequestEntity) async throws
}
