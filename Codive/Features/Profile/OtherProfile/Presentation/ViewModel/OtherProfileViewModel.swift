//
//  OtherProfileViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI
import Combine

@MainActor
final class OtherProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var displayName: String = ""
    @Published var introText: String = ""
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var profileImageUrl: String?
    @Published var isFollowing: Bool = false
    @Published var isPublic: Bool = true
    @Published var isMe: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Calendar State
    @Published var month: Date = Date() {
        didSet {
            Task {
                await loadMonthlyHistories()
            }
        }
    }
    @Published var selectedDate: Date? = Date() {
        didSet {
            // 선택한 날짜의 기록이 있으면 FeedDetailView로 이동
            if let selectedDate = selectedDate {
                let dateString = selectedDate.toDateString()
                if let historyId = monthlyHistoryIds[dateString] {
                    navigationRouter.navigate(to: .feedDetail(feedId: Int(historyId)))
                }
            }
        }
    }
    @Published var isBlockMenuPresented: Bool = false
    @Published var showBlockAlert: Bool = false
    @Published var showBlockFailureAlert: Bool = false
    @Published var blockErrorMessage: String = ""
    @Published var showHistoryErrorAlert: Bool = false
    @Published var monthlyHistories: [String: String] = [:] // "2026-01-21" -> imageUrl
    @Published var monthlyHistoryIds: [String: Int] = [:] // "2026-01-21" -> historyId
    @Published var favoriteCoordinates: [MyFavoriteLookBookResponseDTO] = []

    // MARK: - Dependencies
    private let memberId: Int
    private let navigationRouter: NavigationRouter
    private let fetchMemberInfoUseCase: FetchMemberInfoUseCase
    private let toggleFollowUseCase: ToggleFollowUseCase
    private let fetchMonthlyHistoryUseCase: FetchMonthlyHistoryUseCase
    private let toggleBlockUseCase: ToggleBlockUseCase
    private let fetchMyFavoriteLookBookUseCase: FetchMyFavoriteLookBookUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    init(
        memberId: Int,
        navigationRouter: NavigationRouter,
        fetchMemberInfoUseCase: FetchMemberInfoUseCase,
        toggleFollowUseCase: ToggleFollowUseCase,
        fetchMonthlyHistoryUseCase: FetchMonthlyHistoryUseCase,
        toggleBlockUseCase: ToggleBlockUseCase,
        fetchMyFavoriteLookBookUseCase: FetchMyFavoriteLookBookUseCase
    ) {
        self.memberId = memberId
        self.navigationRouter = navigationRouter
        self.fetchMemberInfoUseCase = fetchMemberInfoUseCase
        self.toggleFollowUseCase = toggleFollowUseCase
        self.fetchMonthlyHistoryUseCase = fetchMonthlyHistoryUseCase
        self.toggleBlockUseCase = toggleBlockUseCase
        self.fetchMyFavoriteLookBookUseCase = fetchMyFavoriteLookBookUseCase

        NotificationCenter.default.publisher(for: .followDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadProfile()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            let profile = try await fetchMemberInfoUseCase.execute(memberId: memberId)

            self.displayName = profile.nickname
            self.introText = profile.bio ?? ""
            self.followerCount = profile.followerCount
            self.followingCount = profile.followingCount
            self.profileImageUrl = profile.profileImageUrl
            self.isFollowing = profile.isFollowing
            self.isPublic = profile.isPublic
            self.isMe = profile.isMe

            await loadMonthlyHistories()
            await loadFavoriteCoordinates()
        } catch {
            self.errorMessage = TextLiteral.Profile.loadFailure
        }
        isLoading = false
    }

    func loadMonthlyHistories() async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let year = components.year, let month = components.month else { return }

        do {
            // API는 Int64, Int32를 요구하므로 변환
            let items = try await fetchMonthlyHistoryUseCase.execute(
                memberId: Int64(memberId),
                year: Int32(year),
                month: Int32(month)
            )

            var newHistories: [String: String] = [:]
            var newHistoryIds: [String: Int] = [:]
            for item in items where newHistories[item.historyDate] == nil {
                newHistories[item.historyDate] = item.firstImageUrl
                newHistoryIds[item.historyDate] = Int(item.historyId)
            }

            self.monthlyHistories = newHistories
            self.monthlyHistoryIds = newHistoryIds
        } catch {
            showHistoryErrorAlert = true
        }
    }

    func loadFavoriteCoordinates() async {
        do {
            let coordinates = try await fetchMyFavoriteLookBookUseCase.fetchFavoriteCoordinate(memberId: memberId)
            self.favoriteCoordinates = coordinates
        } catch {
            #if DEBUG
            print("최애 코디 로드 실패: \(error)")
            #endif
        }
    }

    // MARK: - Actions

    func onBackTapped() {
        navigationRouter.navigateBack()
    }

    func showBlockMenu() {
        isBlockMenuPresented = true
    }

    func dismissBlockMenu() {
        isBlockMenuPresented = false
    }

    func onBlockTapped() {
        dismissBlockMenu()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showBlockAlert = true
        }
    }

    func confirmBlock() {
        Task {
            do {
                isLoading = true
                try await toggleBlockUseCase.execute(memberId: memberId)
                isLoading = false

                NotificationCenter.default.post(name: .userDidBlock, object: nil)
                navigationRouter.navigateBack()
            } catch {
                isLoading = false
                blockErrorMessage = TextLiteral.Feed.blockFailure
                showBlockFailureAlert = true
            }
        }
    }

    func onFollowerTapped() {
        navigationRouter.navigate(to: .followList(mode: .followers, memberId: memberId, isMe: false))
    }

    func onFollowingTapped() {
        navigationRouter.navigate(to: .followList(mode: .followings, memberId: memberId, isMe: false))
    }

    func onFollowButtonTapped() {
        Task {
            do {
                try await toggleFollowUseCase.execute(memberId: memberId, isPublic: isPublic)
                isFollowing.toggle()

                if isFollowing {
                    followerCount += 1
                } else {
                    followerCount -= 1
                }
                NotificationCenter.default.post(name: .followDidChange, object: nil)
            } catch {
                errorMessage = TextLiteral.Profile.followFailure
            }
        }
    }
    func onMoreFavoriteCodiTapped() {
        navigationRouter.navigate(to: .favoriteCodiList(showHeart: false))
    }
}
