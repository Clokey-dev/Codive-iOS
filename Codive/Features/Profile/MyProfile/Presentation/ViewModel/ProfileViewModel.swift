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
    @Published var favoriteCoordinates: [MyFavoriteLookBookResponseDTO] = []
    
    @Published var isShowingPopup: Bool = false
    @Published var selectedCoordinatePreview: CoordinatePreviewEntity?
    @Published var selectedCoordinateDetails: [CoordinateDetailEntity] = []
    
    var popupClothItems: [CodiItem] {
        selectedCoordinateDetails.map { detail in
            CodiItem(
                id: detail.coordinateClothId,
                imageName: detail.imageUrl,
                brand: detail.brand,
                name: detail.name,
                clothId: detail.clothId
            )
        }
    }
    
    var popupPayloads: [Payloads] {
        selectedCoordinateDetails.map { detail in
            Payloads(
                clothId: detail.clothId,
                locationX: detail.locationX,
                locationY: detail.locationY,
                ratio: detail.ratio,
                degree: detail.degree,
                order: detail.order
            )
        }
    }
    
    // MARK: - State
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
                } else {
                    // 기록이 없으면 콜백 호출
                    onEmptyHistoryDateSelected?(selectedDate)
                }
            }
        }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var monthlyHistories: [String: String] = [:] // "2026-01-21" -> imageUrl
    @Published var monthlyHistoryIds: [String: Int] = [:] // "2026-01-21" -> historyId

    // MARK: - Dependencies
    private let navigationRouter: NavigationRouter
    private let fetchMyProfileUseCase: FetchMyProfileUseCase
    private let fetchMonthlyHistoryUseCase: FetchMonthlyHistoryUseCase
    private let fetchFavoriteLookBookUseCase: FetchFavoriteLookBookUseCase

    // MARK: - Callbacks
    var onEmptyHistoryDateSelected: ((Date) -> Void)?

    // MARK: - Initializer
    init(
        navigationRouter: NavigationRouter,
        fetchMyProfileUseCase: FetchMyProfileUseCase,
        fetchMonthlyHistoryUseCase: FetchMonthlyHistoryUseCase,
        fetchFavoriteLookBookUseCase: FetchFavoriteLookBookUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.fetchMyProfileUseCase = fetchMyProfileUseCase
        self.fetchMonthlyHistoryUseCase = fetchMonthlyHistoryUseCase
        self.fetchFavoriteLookBookUseCase = fetchFavoriteLookBookUseCase
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
            #if DEBUG
            print("[Profile] 프로필 로드 실패: \(error.localizedDescription)")
            #endif
        }
        
        isLoading = false
        
        // 프로필 로드 후 캘린더 데이터 로드
        await loadMonthlyHistories()
        
        await loadFavoriteCoordinates()
    }
    
    func loadMonthlyHistories() async {
        guard userId != 0 else { return }
        
        let calendar = Calendar.current
        let year = Int32(calendar.component(.year, from: month))
        let monthValue = Int32(calendar.component(.month, from: month))
        
        do {
            let items = try await fetchMonthlyHistoryUseCase.execute(
                memberId: Int64(userId),
                year: year,
                month: monthValue
            )
            
            // 같은 날짜에 여러 기록이 있으면 첫 번째만 사용
            var historyMap: [String: String] = [:]
            var historyIdMap: [String: Int] = [:]
            for item in items where historyMap[item.historyDate] == nil {
                historyMap[item.historyDate] = item.firstImageUrl
                historyIdMap[item.historyDate] = Int(item.historyId)
            }
            
            self.monthlyHistories = historyMap
            self.monthlyHistoryIds = historyIdMap
        } catch {
            #if DEBUG
            print("[Profile] 월별 기록 로드 실패: \(error.localizedDescription)")
            #endif
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
        navigationRouter.navigate(to: .followList(mode: .followers, memberId: userId, isMe: true))
    }

    func onFollowingTapped() {
        navigationRouter.navigate(to: .followList(mode: .followings, memberId: userId, isMe: true))
    }
    
    func onMoreFavoriteCodiTapped() {
        navigationRouter.navigate(to: .favoriteCodiList(showHeart: true, memberId: nil))
    }
    
    func loadFavoriteCoordinates() async {
        do {
            let coordinates = try await fetchFavoriteLookBookUseCase.fetchFavoriteCoordinate(memberId: nil)
            self.favoriteCoordinates = coordinates
        } catch {
            #if DEBUG
            print("[Profile] 최애 코디 로드 실패: \(error)")
            #endif
        }
    }
    
    func onCodiCardTapped(coordinateId: Int64) {
        Task {
            do {
                self.selectedCoordinatePreview = try await fetchFavoriteLookBookUseCase.fetchCoordinatePreview(coordinateId: coordinateId)
                self.selectedCoordinateDetails = try await fetchFavoriteLookBookUseCase.fetchCoordinateDetail(coordinateId: coordinateId)
                self.isShowingPopup = true
            } catch {
                #if DEBUG
                print("[Profile] 코디 상세 정보 로드 실패: \(error)")
                #endif
            }
        }
    }
}
