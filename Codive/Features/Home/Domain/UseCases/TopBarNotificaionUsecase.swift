//
//  TopBarNotificaionUsecase.swift
//  Codive
//
//  Created by 한금준 on 1/25/26.
//

import Foundation

final class TopBarNotificaionUsecase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    func fetchNotificationExist() async throws -> NotificationExistAPIResponseDTO {
        return try await repository.fetchNotificationExist()
    }
}
