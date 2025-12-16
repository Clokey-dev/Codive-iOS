//
//  CommentDIContainer.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation

@MainActor
final class CommentDIContainer {
    
    // MARK: - Properties
    let navigationRouter: NavigationRouter
    lazy var commentViewFactory = CommentViewFactory(commentDIContainer: self)

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    // MARK: - DataSources

    private lazy var commentDataSource: CommentDataSource = {
        // 나중에 실제 API가 구현되면 이 부분만 DefaultCommentDataSource()로 교체
        return MockCommentDataSource()
    }()

    // MARK: - Repositories

    private lazy var commentRepository: CommentRepository = {
        return CommentRepositoryImpl(dataSource: commentDataSource)
    }()

    // MARK: - UseCases

    func makeFetchCommentsUseCase() -> FetchCommentsUseCase {
        return DefaultFetchCommentsUseCase(commentRepository: commentRepository)
    }

    func makePostCommentUseCase() -> PostCommentUseCase {
        return DefaultPostCommentUseCase(commentRepository: commentRepository)
    }

    // MARK: - ViewModels

    func makeCommentViewModel(feedId: Int) -> CommentViewModel {
        return CommentViewModel(
            feedId: feedId,
            fetchCommentsUseCase: makeFetchCommentsUseCase(),
            postCommentUseCase: makePostCommentUseCase()
        )
    }

    // MARK: - Views

    func makeCommentView(feedId: Int) -> CommentView {
        return CommentView(viewModel: self.makeCommentViewModel(feedId: feedId))
    }
}
