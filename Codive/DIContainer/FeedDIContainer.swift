//
//  FeedDIContainer.swift
//  Codive
//
//  Created by 황상환 on 2025/11/22.
//

import Foundation

final class FeedDIContainer {

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

    // MARK: - ViewModels

    @MainActor
    func makeFeedViewModel() -> FeedViewModel {
        return FeedViewModel(
            fetchFeedsUseCase: makeFetchFeedsUseCase(),
            feedRepository: feedRepository
        )
    }
}
