import Foundation
import UserNotifications
import UIKit

@MainActor
final class SettingViewModel: ObservableObject {

    // UI 토글 값
    @Published var isPushOn: Bool = false
    @Published var isMarketingOn: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    private var hasLoaded = false

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
        guard !hasLoaded else { return }
        isLoading = true
        error = nil

        do {
            // 프로필 정보 로드
            await profileViewModel.loadMyProfile()

            // 시스템 푸시 권한 상태 확인
            await refreshPushPermissionStatus()

            // 마케팅 동의 설정 로드
            let prefs = try await getPrefsUC.fetch()
            isMarketingOn = prefs.marketingOptIn
            hasLoaded = true
        } catch {
            self.error = error
        }

        isLoading = false
    }

    // MARK: - Push Notification

    /// 시스템 알림 권한 상태를 확인하여 토글에 반영
    func refreshPushPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isPushOn = settings.authorizationStatus == .authorized
    }

    /// 푸시 토글 탭 시 iOS 설정 앱으로 이동
    func openPushSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Marketing

    func updateMarketing(_ newValue: Bool) {
        isMarketingOn = newValue
        Task { await saveMarketingPrefs() }
    }

    private func saveMarketingPrefs() async {
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
        guard let url = URL(string: "https://pf.kakao.com/_amHbn") else { return }
        UIApplication.shared.open(url)
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
