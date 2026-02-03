import Foundation

@MainActor
final class WithdrawViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var showConfirmAlert: Bool = false

    private let navigationRouter: NavigationRouter
    private let appRouter: AppRouter
    private let withdrawUC: WithdrawAccountUseCase

    init(
        navigationRouter: NavigationRouter,
        appRouter: AppRouter,
        withdrawUC: WithdrawAccountUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.appRouter = appRouter
        self.withdrawUC = withdrawUC
    }

    func onWithdrawTapped() {
        showConfirmAlert = true
    }

    func confirmWithdraw() {
        isLoading = true
        Task {
            do {
                try await withdrawUC.execute()

                await MainActor.run {
                    isLoading = false
                    appRouter.logout()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("탈퇴 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func navigateBack() {
        navigationRouter.navigateBack()
    }
}
