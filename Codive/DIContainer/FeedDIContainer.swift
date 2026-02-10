//
//  FeedDIContainer.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation

@MainActor
final class FeedDIContainer {

    // MARK: - Properties
    let navigationRouter: NavigationRouter
    lazy var feedViewFactory = FeedViewFactory(feedDIContainer: self, navigationRouter: navigationRouter)
    lazy var commentDIContainer = CommentDIContainer(navigationRouter: navigationRouter)
    lazy var profileDIContainer = ProfileDIContainer(navigationRouter: navigationRouter)

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    // MARK: - DataSources

    private lazy var recordDataSource: RecordDataSource = {
        return DefaultRecordDataSource()
    }()

    private lazy var feedDataSource: FeedDataSource = {
        return DefaultFeedDataSource()
    }()

    // MARK: - Repositories

    private lazy var recordRepository: RecordRepository = {
        return DefaultRecordRepository(dataSource: recordDataSource)
    }()

    private lazy var feedRepository: FeedRepository = {
        return FeedRepositoryImpl(
            dataSource: feedDataSource,
            historyAPIService: HistoryAPIService()
        )
    }()

    private lazy var historyRepository: HistoryRepository = {
        return HistoryRepositoryImpl(historyAPIService: HistoryAPIService())
    }()

    // MARK: - UseCases

    func makeCreateRecordUseCase() -> CreateRecordUseCase {
        return DefaultCreateRecordUseCase(repository: recordRepository)
    }

    func makeFetchFeedsUseCase() -> FetchFeedsUseCase {
        return DefaultFetchFeedsUseCase(repository: feedRepository)
    }

    func makeFetchFeedDetailUseCase() -> FetchFeedDetailUseCase {
        return DefaultFetchFeedDetailUseCase(repository: feedRepository)
    }
    
    func makeFetchFeedLikersUseCase() -> FetchFeedLikersUseCase {
        return DefaultFetchFeedLikersUseCase(feedRepository: feedRepository)
    }

    func makeToggleLikeUseCase() -> ToggleLikeUseCase {
        return DefaultToggleLikeUseCase(feedRepository: feedRepository)
    }

    func makeFetchClothTagsUseCase() -> FetchClothTagsUseCase {
        return DefaultFetchClothTagsUseCase(feedRepository: feedRepository)
    }

    // MARK: - ViewModels

    func makeFeedViewModel() -> FeedViewModel {
        return FeedViewModel(
            navigationRouter: navigationRouter,
            fetchFeedsUseCase: makeFetchFeedsUseCase(),
            toggleLikeUseCase: makeToggleLikeUseCase()
        )
    }

    func makeFeedDetailViewModel(feedId: Int) -> FeedDetailViewModel {
        return FeedDetailViewModel(
            feedId: feedId,
            fetchFeedDetailUseCase: makeFetchFeedDetailUseCase(),
            fetchLikersUseCase: makeFetchFeedLikersUseCase(),
            toggleLikeUseCase: makeToggleLikeUseCase(),
            fetchClothTagsUseCase: makeFetchClothTagsUseCase(),
            historyRepository: historyRepository,
            navigationRouter: navigationRouter
        )
    }

    // MARK: - Views

    func makeFeedDetailView(feedId: Int) -> FeedDetailView {
        return FeedDetailView(
            viewModel: makeFeedDetailViewModel(feedId: feedId),
            navigationRouter: navigationRouter,
            commentDIContainer: commentDIContainer
        )
    }

    func makeRecordDetailViewForEdit(feed: Feed) -> RecordDetailView {
        let viewModel = RecordDetailViewModel(
            feed: feed,
            navigationRouter: navigationRouter,
            recordDataSource: DefaultRecordDataSource()
        )
        return RecordDetailView(viewModel: viewModel)
    }
}

#if DEBUG
extension FeedDIContainer {
    @MainActor
    static func makeFeedDetailViewModelForPreview(
        feedId: Int,
        repository: FeedRepository,
        navigationRouter: NavigationRouter
    ) -> FeedDetailViewModel {
        let detailUseCase = DefaultFetchFeedDetailUseCase(repository: repository)
        let likersUseCase = DefaultFetchFeedLikersUseCase(feedRepository: repository)
        let toggleLikeUseCase = DefaultToggleLikeUseCase(feedRepository: repository)
        let clothTagsUseCase = DefaultFetchClothTagsUseCase(feedRepository: repository)
        let mockHistoryRepository = HistoryRepositoryImpl()
        return FeedDetailViewModel(
            feedId: feedId,
            fetchFeedDetailUseCase: detailUseCase,
            fetchLikersUseCase: likersUseCase,
            toggleLikeUseCase: toggleLikeUseCase,
            fetchClothTagsUseCase: clothTagsUseCase,
            historyRepository: mockHistoryRepository,
            navigationRouter: navigationRouter
        )
    }
}
#endif
