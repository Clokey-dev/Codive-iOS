//
//  WardrobeReportDetailViewModel.swift
//  Codive
//
//  Created by 황상환 on 2/26/26.
//

import Foundation

@MainActor
final class WardrobeReportDetailViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var canAggregate: Bool = false
    @Published var isShowingNetworkErrorAlert: Bool = false
    @Published var networkErrorMessage: String?

    // MARK: - Computed Properties
    var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }

    // MARK: - Private Properties
    private let navigationRouter: NavigationRouter
    private let checkStatisticsConditionUseCase: CheckStatisticsConditionUseCase

    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        checkStatisticsConditionUseCase: CheckStatisticsConditionUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.checkStatisticsConditionUseCase = checkStatisticsConditionUseCase
    }

    // MARK: - Methods
    func checkCondition() async {
        isLoading = true
        do {
            canAggregate = try await checkStatisticsConditionUseCase.execute()
        } catch {
            canAggregate = false
            networkErrorMessage = "네트워크 오류가 발생했습니다. 다시 시도해주세요."
            isShowingNetworkErrorAlert = true
            #if DEBUG
            print("[WardrobeReport] 통계 조건 확인 실패: \(error)")
            #endif
        }
        isLoading = false
    }

    // MARK: - Navigation
    func navigateBack() {
        navigationRouter.navigateBack()
    }

    func navigateToRecordAdd() {
        navigationRouter.navigate(to: .recordAdd)
    }
}
