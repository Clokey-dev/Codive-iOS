//
//  TopNavigationNotificaionUsecase.swift
//  Codive
//
//  Created by 한금준 on 1/25/26.
//

import Foundation

final class TopNavigationNotificaionUsecase {

    private let repository: NotificationRepository

    init(repository: NotificationRepository) {
        self.repository = repository
    }

    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO {
        return try await repository.fetchNotificationExist()
    }
}
