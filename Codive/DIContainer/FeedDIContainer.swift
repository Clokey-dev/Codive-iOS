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
    lazy var feedViewFactory = FeedViewFactory(feedDIContainer: self)

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    // MARK: - DataSources

    private lazy var recordDataSource: RecordDataSource = {
        return DefaultRecordDataSource()
    }()

    private lazy var feedDataSource: FeedDataSource = {
        return MockFeedDataSource()
    }()

    // MARK: - Repositories

    private lazy var recordRepository: RecordRepository = {
        return DefaultRecordRepository(dataSource: recordDataSource)
    }()

    private lazy var feedRepository: FeedRepository = {
        return FeedRepositoryImpl(dataSource: feedDataSource)
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

    // MARK: - ViewModels

    func makeFeedViewModel() -> FeedViewModel {
        return FeedViewModel(
            navigationRouter: navigationRouter,
            fetchFeedsUseCase: makeFetchFeedsUseCase(),
            feedRepository: feedRepository
        )
    }

    func makeFeedDetailViewModel(feedId: Int) -> FeedDetailViewModel {
        return FeedDetailViewModel(
            feedId: feedId,
            fetchFeedDetailUseCase: makeFetchFeedDetailUseCase(),
            fetchLikersUseCase: makeFetchFeedLikersUseCase(),
            feedRepository: feedRepository,
            navigationRouter: navigationRouter
        )
    }

    // MARK: - Views

    func makeFeedDetailView(feedId: Int) -> FeedDetailView {
        return FeedDetailView(
            viewModel: makeFeedDetailViewModel(feedId: feedId),
            navigationRouter: navigationRouter
        )
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
        let useCase = DefaultFetchFeedDetailUseCase(repository: repository)
        let likersUseCase = DefaultFetchFeedLikersUseCase(feedRepository: repository) // FetchFeedLikersUseCase 추가
        return FeedDetailViewModel(
            feedId: feedId,
            fetchFeedDetailUseCase: useCase,
            fetchLikersUseCase: likersUseCase,
            feedRepository: repository,
            navigationRouter: navigationRouter
        )
    }
}
#endif
