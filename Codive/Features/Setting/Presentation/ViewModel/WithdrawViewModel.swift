import Foundation

@MainActor
final class WithdrawViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var showConfirmAlert: Bool = false

    private let navigationRouter: NavigationRouter

    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    func onWithdrawTapped() {
        showConfirmAlert = true
    }

    func confirmWithdraw() {
        isLoading = true
        // TODO: 실제 탈퇴 API 호출
        // 이후 AppRouter를 통해 로그인 화면으로 이동
        isLoading = false
    }

    func navigateBack() {
        navigationRouter.navigateBack()
    }
}
