//
//  AlarmViewFactory.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

@MainActor
final class AlarmViewFactory {
    private weak var alarmDIContainer: AlarmDIContainer?
    
    // MARK: - Initializer
    init(alarmDIContainer: AlarmDIContainer) {
        self.alarmDIContainer = alarmDIContainer
    }
    
    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .alarm:
            alarmDIContainer?.makeAlarmView()
        default:
            EmptyView()
        }
    }
}
