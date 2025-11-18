//
//  AlarmDIContainer.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import Foundation

@MainActor
final class AlarmDIContainer {
    let navigationRouter: NavigationRouter
    lazy var alarmViewFactory = AlarmViewFactory(alarmDIContainer: self)
    
    lazy var alarmDataSource = AlarmDataSource()
    
    lazy var alarmRepository: AlarmRepository = AlarmRepositoryImpl(datasource: alarmDataSource)
    
    lazy var alarmUseCase = AlarmUseCase(repository: alarmRepository)
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    func makeAlarmViewModel() -> AlarmViewModel {
        return AlarmViewModel(
            navigationRouter: navigationRouter,
            useCase: alarmUseCase
        )
    }
    
    func makeAlarmView() -> AlarmView {
        return AlarmView(viewModel: makeAlarmViewModel())
    }
}
