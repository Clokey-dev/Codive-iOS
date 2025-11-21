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
}
