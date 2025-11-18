//
//  AlarmRepositoryImpl.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

final class NotificationRepositoryImpl: NotificationRepository {
    private let datasource: NotificationDataSource
    
    init(datasource: NotificationDataSource) {
        self.datasource = datasource
    }
    
    func fetchNotifications() -> [NotificationEntity] {
        return datasource.fetchNotifications()
    }
}
