//
//  CommentDIContainer.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation
import CodiveAPI

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
        return DefaultCommentDataSource()
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

    func makeFetchRepliesUseCase() -> FetchRepliesUseCase {
        return DefaultFetchRepliesUseCase(commentRepository: commentRepository)
    }

    func makePostReplyUseCase() -> PostReplyUseCase {
        return DefaultPostReplyUseCase(commentRepository: commentRepository)
    }

    // MARK: - ViewModels

    func makeCommentViewModel(feedId: Int) -> CommentViewModel {
        return CommentViewModel(
            feedId: feedId,
            fetchCommentsUseCase: makeFetchCommentsUseCase(),
            postCommentUseCase: makePostCommentUseCase(),
            fetchRepliesUseCase: makeFetchRepliesUseCase(),
            postReplyUseCase: makePostReplyUseCase()
        )
    }

    // MARK: - Views

    func makeCommentView(feedId: Int) -> CommentView {
        return CommentView(viewModel: self.makeCommentViewModel(feedId: feedId))
    }
}
