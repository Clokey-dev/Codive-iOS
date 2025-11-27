//
//  AlarmViewFactory.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

@MainActor
final class NotificationViewFactory {
    private weak var notificationDIContainer: NotificationDIContainer?
    
    // MARK: - Initializer
    init(notificationDIContainer: NotificationDIContainer) {
        self.notificationDIContainer = notificationDIContainer
    }
    
    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .notification:
            notificationDIContainer?.makeNotificationView()
        default:
            EmptyView()
        }
    }
}
