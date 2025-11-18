//
//  AlarmUseCase.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

final class NotificationUseCase {
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func fetchNotifications() -> [NotificationEntity] {
        return repository.fetchNotifications()
    }
}
