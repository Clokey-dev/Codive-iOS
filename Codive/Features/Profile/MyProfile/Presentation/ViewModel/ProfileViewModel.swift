//
//  ProfileViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Profile Data
    @Published var userId: Int = 0
    @Published var username: String = ""
    @Published var displayName: String = ""
    @Published var introText: String = ""
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var profileImageUrl: String?
    @Published var email: String?

    // MARK: - State
    @Published var month: Date = Date() {
        didSet {
            Task {
                await loadMonthlyHistories()
            }
        }
    }
    @Published var selectedDate: Date? = Date()        // 선택된 날짜
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var monthlyHistories: [String: String] = [:] // "2026-01-21" -> imageUrl

    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter
    private let fetchMyProfileUseCase: FetchMyProfileUseCase
    private let historyAPIService: HistoryAPIServiceProtocol

    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        fetchMyProfileUseCase: FetchMyProfileUseCase,
        historyAPIService: HistoryAPIServiceProtocol = HistoryAPIService()
    ) {
        self.navigationRouter = navigationRouter
        self.fetchMyProfileUseCase = fetchMyProfileUseCase
        self.historyAPIService = historyAPIService
    }
    
    // MARK: - Loading
    func loadMyProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            let profileInfo = try await fetchMyProfileUseCase.execute()
            self.userId = profileInfo.userId
            self.username = profileInfo.nickname
            self.displayName = profileInfo.displayName
            self.introText = profileInfo.introduction ?? ""
            self.followerCount = profileInfo.followerCount
            self.followingCount = profileInfo.followingCount
            self.profileImageUrl = profileInfo.profileImageUrl
            self.email = profileInfo.email
        } catch {
            self.errorMessage = error.localizedDescription
            print("프로필 로드 실패: \(error.localizedDescription)")
        }

        isLoading = false

        // 프로필 로드 후 캘린더 데이터 로드
        await loadMonthlyHistories()
    }

    func loadMonthlyHistories() async {
        guard userId != 0 else { return }

        let calendar = Calendar.current
        let year = Int32(calendar.component(.year, from: month))
        let monthValue = Int32(calendar.component(.month, from: month))

        do {
            let items = try await historyAPIService.fetchMonthlyHistory(
                memberId: Int64(userId),
                year: year,
                month: monthValue
            )

            // 같은 날짜에 여러 기록이 있으면 첫 번째만 사용
            var historyMap: [String: String] = [:]
            for item in items {
                if historyMap[item.historyDate] == nil {
                    historyMap[item.historyDate] = item.firstImageUrl
                }
            }

            self.monthlyHistories = historyMap
        } catch {
            print("월별 기록 로드 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Actions
    func onEditProfileTapped() {
        navigationRouter.navigate(to: .profileSetting)
    }

    func onSettingsTapped() {
        navigationRouter.navigate(to: .settings)
    }

    func onFollowerTapped() {
        navigationRouter.navigate(to: .followList(mode: .followers, memberId: userId))
    }

    func onFollowingTapped() {
        navigationRouter.navigate(to: .followList(mode: .followings, memberId: userId))
    }

    func onMoreFavoriteCodiTapped() {
        navigationRouter.navigate(to: .favoriteCodiList(showHeart: true))
    }
}
