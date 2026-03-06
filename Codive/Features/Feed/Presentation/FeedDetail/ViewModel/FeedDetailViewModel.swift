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

    // MARK: - Constants

    private enum Constants {
        static let menuDismissDelay: TimeInterval = 0.3
    }

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
    @Published var showBlockFailureAlert: Bool = false // 차단 실패 Alert
    @Published var blockErrorMessage: String = "" // 차단 실패 에러 메시지

    // MARK: - Private Properties

    private let feedId: Int
    private let fetchFeedDetailUseCase: FetchFeedDetailUseCase
    private let fetchLikersUseCase: FetchFeedLikersUseCase
    private let toggleLikeUseCase: ToggleLikeUseCase
    private let fetchClothTagsUseCase: FetchClothTagsUseCase
    private let deleteHistoryUseCase: DeleteHistoryUseCase
    private let toggleBlockUseCase: ToggleBlockUseCase
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
        deleteHistoryUseCase: DeleteHistoryUseCase,
        toggleBlockUseCase: ToggleBlockUseCase,
        navigationRouter: NavigationRouter
    ) {
        self.feedId = feedId
        self.fetchFeedDetailUseCase = fetchFeedDetailUseCase
        self.fetchLikersUseCase = fetchLikersUseCase
        self.toggleLikeUseCase = toggleLikeUseCase
        self.fetchClothTagsUseCase = fetchClothTagsUseCase
        self.deleteHistoryUseCase = deleteHistoryUseCase
        self.toggleBlockUseCase = toggleBlockUseCase
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
            errorMessage = TextLiteral.Feed.likeFailure
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
    /// 프로필로 이동 (스택에 같은 유저의 OtherProfile이 있으면 pop back)
    func navigateToProfile(userId: UserID, isMine: Bool) {
        if isMine {
            navigationRouter.navigate(to: .myProfile)
        } else {
            guard let memberId = Int(userId) else { return }
            let found = navigationRouter.popTo { destination in
                if case .otherProfile(let existingId) = destination {
                    return existingId == memberId
                }
                return false
            }
            if !found {
                navigationRouter.navigate(to: .otherProfile(userId: memberId))
            }
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
        showAlertAfterDismissingMenu { [weak self] in
            self?.showDeleteAlert = true
        }
    }

    func confirmDelete() {
        guard let feed = feed else {
            return
        }

        Task {
            do {
                isLoading = true
                // API는 Int64를 요구하므로 변환
                let historyId = Int64(feed.id)
                try await deleteHistoryUseCase.execute(historyId: historyId)
                isLoading = false
                navigationRouter.navigateBack()
            } catch {
                isLoading = false
                errorMessage = TextLiteral.Feed.deleteFailure
            }
        }
    }

    func onReportTapped() {
        dismissMoreMenu()
        guard let feed = feed else { return }
        navigationRouter.navigate(to: .report(target: .post(id: feed.id)))
    }

    func onBlockTapped() {
        showAlertAfterDismissingMenu { [weak self] in
            self?.showBlockAlert = true
        }
    }

    // MARK: - Private Helper Methods

    private func showAlertAfterDismissingMenu(completion: @escaping () -> Void) {
        dismissMoreMenu()
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.menuDismissDelay) {
            completion()
        }
    }

    func confirmBlock() {
        guard let feed = feed else {
            blockErrorMessage = TextLiteral.Feed.invalidUserInfo
            showBlockFailureAlert = true
            return
        }

        // User.id는 String이므로 Int로 변환 필요
        guard let memberId = Int(feed.author.id) else {
            blockErrorMessage = TextLiteral.Feed.invalidUserInfo
            showBlockFailureAlert = true
            return
        }

        Task {
            do {
                isLoading = true
                try await toggleBlockUseCase.execute(memberId: memberId)
                isLoading = false

                // 차단 성공 알림 발송
                NotificationCenter.default.post(name: .userDidBlock, object: nil)

                // 성공 시 바로 뒤로가기
                navigationRouter.navigateBack()
            } catch {
                isLoading = false
                blockErrorMessage = TextLiteral.Feed.blockFailure
                showBlockFailureAlert = true
            }
        }
    }
}
