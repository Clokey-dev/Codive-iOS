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
}
