import Foundation
import CodiveAPI

@MainActor
final class WithdrawViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var showConfirmAlert: Bool = false

    private let navigationRouter: NavigationRouter
    private let appRouter: AppRouter
    private let apiClient: Client

    init(navigationRouter: NavigationRouter, appRouter: AppRouter, apiClient: Client = CodiveAPIProvider.createClient(middlewares: [CodiveAuthMiddleware(provider: KeychainTokenProvider())])) {
        self.navigationRouter = navigationRouter
        self.appRouter = appRouter
        self.apiClient = apiClient
    }

    func onWithdrawTapped() {
        showConfirmAlert = true
    }

    func confirmWithdraw() {
        isLoading = true
        Task {
            do {
                let response = try await apiClient.Auth_withdrawMember()

                switch response {
                case .ok:
                    // 탈퇴 성공 - 로그인 화면으로 이동
                    await MainActor.run {
                        isLoading = false
                        appRouter.logout()
                    }
                default:
                    await MainActor.run {
                        isLoading = false
                    }
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
