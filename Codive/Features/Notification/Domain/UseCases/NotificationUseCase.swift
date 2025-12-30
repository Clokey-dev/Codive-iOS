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
    func fetchNotifications() -> [NotificationEntity] {
        return repository.fetchNotifications()
    }
    
    func fetchReportStatus() -> ReportEntity {
        return repository.fetchReportStatus()
    }
    
    func markNotificationAsRead(notificationId: Int) async {
        let request = NotificationReadRequestEntity(notificationId: notificationId)
        do {
            try await repository.markNotificationAsRead(request: request)
        } catch {
            print("알림 읽음 처리 실패: \(error)")
        }
    }
}
