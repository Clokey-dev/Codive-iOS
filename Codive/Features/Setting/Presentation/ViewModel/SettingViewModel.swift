import Foundation

@MainActor
final class SettingViewModel: ObservableObject {

    // UI 토글 값
    @Published var isPushOn: Bool = false
    @Published var isMarketingOn: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?

    private let appRouter: AppRouter
    private let navigationRouter: NavigationRouter
    private let getPrefsUC: GetNotificationPrefsUseCase
    private let updatePrefsUC: UpdateNotificationPrefsUseCase
    private let authRepository: AuthRepository
    let profileViewModel: ProfileViewModel

    init(
        appRouter: AppRouter,
        navigationRouter: NavigationRouter,
        getPrefsUC: GetNotificationPrefsUseCase,
        updatePrefsUC: UpdateNotificationPrefsUseCase,
        authRepository: AuthRepository,
        profileViewModel: ProfileViewModel
    ) {
        self.appRouter = appRouter
        self.navigationRouter = navigationRouter
        self.getPrefsUC = getPrefsUC
        self.updatePrefsUC = updatePrefsUC
        self.authRepository = authRepository
        self.profileViewModel = profileViewModel
    }

    // 초기 로드
    func load() async {
        isLoading = true
        error = nil

        do {
            // 프로필 정보 로드
            await profileViewModel.loadMyProfile()

            let prefs = try await getPrefsUC.fetch()
            isPushOn = prefs.pushEnabled
            isMarketingOn = prefs.marketingOptIn
        } catch {
            self.error = error
        }

        isLoading = false
    }

    // 토글 핸들러
    func updatePush(_ newValue: Bool) {
        isPushOn = newValue
        Task { await save() }
    }

    func updateMarketing(_ newValue: Bool) {
        isMarketingOn = newValue
        Task { await save() }
    }

    // 서버 저장
    private func save() async {
        let prefs = NotificationPrefs(
            pushEnabled: isPushOn,
            marketingOptIn: isMarketingOn
        )

        do {
            try await updatePrefsUC.update(prefs)
        } catch {
            self.error = error
        }
    }

    // MARK: - Navigation
    func navigateBack() {
        navigationRouter.navigateBack()
    }

    func navigateToLikedRecords() {
        navigationRouter.navigate(to: .settingLikedRecords)
    }

    func navigateToMyComments() {
        navigationRouter.navigate(to: .settingMyComments)
    }

    func navigateToBlockedUsers() {
        navigationRouter.navigate(to: .settingBlockedUsers)
    }

    func navigateToInquiry() {
        // TODO: 문의하기 화면으로 이동
        // 아직 구현되지 않은 화면입니다.
    }

    func navigateToWithdraw() {
        navigationRouter.navigate(to: .settingWithdraw)
    }

    // MARK: - Logout
    func logout() async {
        // Domain/Data 레이어: 토큰 삭제 및 소셜 로그아웃
        await authRepository.logout()

        // Presentation 레이어: AppRouter가 모든 네비게이션 관리
        // (Router가 navigationRouter를 소유하고 navigateToRoot + 상태 변경 수행)
        appRouter.logout()
    }
}
