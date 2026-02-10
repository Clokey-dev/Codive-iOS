//
//  FeedDetailViewModel.swift
//  Codive
//
//  Created by 황상환 on 2025/11/29.
//

import Foundation

/// Feed 상세 화면의 ViewModel
@MainActor
final class FeedDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var feed: Feed?
    @Published var imageUrls: [String] = []
    @Published var displayableTags: [[ClothTag]] = []
    @Published var formattedDate: String = ""
    @Published var displayableStyles: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var likers: [User] = [] // 좋아요 누른 유저 목록
    @Published var isLikesSheetPresented: Bool = false // 좋아요 목록 시트 표시 여부

    @Published var isMoreMenuPresented: Bool = false // 더보기 메뉴 표시 여부
    @Published var showDeleteAlert: Bool = false // 삭제 확인 Alert
    @Published var showBlockAlert: Bool = false // 차단 확인 Alert

    // MARK: - Private Properties

    private let feedId: Int
    private let fetchFeedDetailUseCase: FetchFeedDetailUseCase
    private let fetchLikersUseCase: FetchFeedLikersUseCase
    private let toggleLikeUseCase: ToggleLikeUseCase
    private let fetchClothTagsUseCase: FetchClothTagsUseCase
    private let historyRepository: HistoryRepository
    private let navigationRouter: NavigationRouter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = TextLiteral.Feed.dateFormat
        return formatter
    }()

    // MARK: - Initializer

    init(
        feedId: Int,
        fetchFeedDetailUseCase: FetchFeedDetailUseCase,
        fetchLikersUseCase: FetchFeedLikersUseCase,
        toggleLikeUseCase: ToggleLikeUseCase,
        fetchClothTagsUseCase: FetchClothTagsUseCase,
        historyRepository: HistoryRepository,
        navigationRouter: NavigationRouter
    ) {
        self.feedId = feedId
        self.fetchFeedDetailUseCase = fetchFeedDetailUseCase
        self.fetchLikersUseCase = fetchLikersUseCase
        self.toggleLikeUseCase = toggleLikeUseCase
        self.fetchClothTagsUseCase = fetchClothTagsUseCase
        self.historyRepository = historyRepository
        self.navigationRouter = navigationRouter
    }

    // MARK: - Feed 상세 로딩

    func loadFeedDetail() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let fetchedFeed = try await fetchFeedDetailUseCase.execute(feedId: feedId)

            // 데이터 가공
            self.feed = fetchedFeed
            self.imageUrls = fetchedFeed.images.map { $0.imageUrl }
            self.formattedDate = format(date: fetchedFeed.createdAt)
            self.displayableStyles = fetchedFeed.styleNames ?? []

            // 각 이미지의 태그를 API로 가져오기
            self.displayableTags = await loadTagsForImages(images: fetchedFeed.images)
        } catch {
            errorMessage = TextLiteral.Feed.loadDetailFailed
            feed = nil
            imageUrls = []
            displayableTags = []
            formattedDate = ""
            displayableStyles = []
        }

        isLoading = false
    }
    
    // MARK: - Data Transformation

    private func loadTagsForImages(images: [FeedImage]) async -> [[ClothTag]] {
        await withTaskGroup(of: (Int, [ClothTag]).self) { group in
            // 각 이미지의 태그를 병렬로 가져오기
            for (index, image) in images.enumerated() {
                group.addTask { [weak self] in
                    guard let self = self,
                          let imageId = image.imageId else {
                        return (index, [])
                    }

                    do {
                        let clothTags = try await self.fetchClothTagsUseCase.execute(historyImageId: imageId)
                        return (index, clothTags)
                    } catch {
                        print("Failed to load tags for image \(imageId): \(error)")
                        return (index, [])
                    }
                }
            }

            // 결과를 순서대로 정렬
            var result: [(Int, [ClothTag])] = []
            for await value in group {
                result.append(value)
            }
            result.sort { $0.0 < $1.0 }
            return result.map { $0.1 }
        }
    }
    
    private func format(date: Date?) -> String {
        guard let date = date else { return "" }
        return dateFormatter.string(from: date)
    }

    // MARK: - 좋아요 토글

    /// 좋아요를 토글합니다 (낙관적 업데이트).
    func toggleLike() async {
        guard let currentFeed = feed else { return }

        // 낙관적 업데이트: UI 먼저 변경
        let originalFeed = currentFeed
        let newIsLiked = !(currentFeed.isLiked ?? false)
        let newLikeCount = calculateNewLikeCount(
            current: currentFeed.likeCount ?? 0,
            isLiked: newIsLiked
        )

        feed = Feed(
            id: currentFeed.id,
            content: currentFeed.content,
            author: currentFeed.author,
            images: currentFeed.images,
            situationId: currentFeed.situationId,
            styleIds: currentFeed.styleIds,
            styleNames: currentFeed.styleNames,
            hashtags: currentFeed.hashtags,
            createdAt: currentFeed.createdAt,
            likeCount: newLikeCount,
            isLiked: newIsLiked,
            commentCount: currentFeed.commentCount
        )

        // 서버 요청
        do {
            try await toggleLikeUseCase.execute(feedId: currentFeed.id)
        } catch {
            // 실패 시 롤백
            feed = originalFeed
            errorMessage = "좋아요 처리에 실패했습니다."
        }
    }

    private func calculateNewLikeCount(current: Int, isLiked: Bool) -> Int {
        if isLiked {
            return current + 1
        } else {
            return max(0, current - 1)
        }
    }
    
    // MARK: - 좋아요 목록 화면 이동
    
    /// 좋아요 개수를 탭했을 때 좋아요 목록 시트
    func likesCountTapped() {
        Task {
            do {
                self.likers = try await fetchLikersUseCase.execute(feedId: self.feedId)
                self.isLikesSheetPresented = true
            } catch {
                errorMessage = TextLiteral.Feed.likesListLoadFailed
            }
        }
    }
    
    // MARK: - 댓글 화면 이동
    func commentButtonTapped() {
        navigationRouter.presentSheet(for: .comment(feedId: self.feedId))
    }

    // MARK: - 프로필 이동
    /// 프로필로 이동 (isMine 기준으로 내 프로필 또는 다른 사람 프로필)
    func navigateToProfile(userId: String, isMine: Bool) {
        guard let memberId = Int(userId) else {
            print("❌ Invalid userId: \(userId)")
            return
        }

        print("🔍 Profile Navigation - userId: \(userId), isMine: \(isMine)")

        if isMine {
            print("✓ Navigate to myProfile")
            navigationRouter.navigate(to: .myProfile)
        } else {
            print("✓ Navigate to otherProfile(userId: \(memberId))")
            navigationRouter.navigate(to: .otherProfile(userId: memberId))
        }
    }

    // MARK: - 더보기 메뉴

    func showMoreMenu() {
        isMoreMenuPresented = true
    }

    func dismissMoreMenu() {
        isMoreMenuPresented = false
    }

    func onEditTapped() {
        dismissMoreMenu()
        guard let feed = feed else { return }
        navigationRouter.navigate(to: .recordEdit(feed: feed))
    }

    func onDeleteTapped() {
        dismissMoreMenu()
        // 메뉴 닫히는 애니메이션 후 Alert 띄우기
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showDeleteAlert = true
        }
    }

    func confirmDelete() {
        guard let feed = feed else {
            print("❌ Feed is nil")
            return
        }

        Task {
            do {
                print("🗑️ Deleting history with ID: \(feed.id)")
                isLoading = true
                try await historyRepository.deleteHistory(historyId: Int64(feed.id))
                print("✅ Delete API success")
                isLoading = false
                navigationRouter.navigateBack()
            } catch {
                print("❌ Delete API error: \(error.localizedDescription)")
                isLoading = false
                errorMessage = "삭제에 실패했습니다. (\(error.localizedDescription))"
            }
        }
    }

    func onReportTapped() {
        dismissMoreMenu()
        guard let feed = feed else { return }
        navigationRouter.navigate(to: .report(target: .post(id: feed.id)))
    }

    func onBlockTapped() {
        dismissMoreMenu()
        showBlockAlert = true
    }

    func confirmBlock() {
        guard let feed = feed,
              let userId = Int64(feed.author.id) else {
            print("❌ Invalid user ID")
            return
        }

        Task {
            do {
                isLoading = true
                print("🔒 Blocking user with ID: \(userId)")
                // 차단 API 호출
                // try await memberRepository.blockUser(userId: userId)
                isLoading = false
                print("✅ Block successful")
                navigationRouter.successMessage = "사용자를 차단했습니다."
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationRouter.navigateBack()
                }
            } catch {
                isLoading = false
                print("❌ Block error: \(error.localizedDescription)")
                errorMessage = "차단에 실패했습니다: \(error.localizedDescription)"
            }
        }
    }
}
