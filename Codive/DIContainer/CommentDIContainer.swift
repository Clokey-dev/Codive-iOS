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

    private lazy var otherProfileRepository: OtherProfileRepository = {
        return OtherProfileRepositoryImpl(apiService: ProfileAPIService())
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

    func makeToggleBlockUseCase() -> ToggleBlockUseCase {
        return DefaultToggleBlockUseCase(repository: otherProfileRepository)
    }

    // MARK: - ViewModels

    func makeCommentViewModel(feedId: Int) -> CommentViewModel {
        let viewModel = CommentViewModel(
            feedId: feedId,
            navigationRouter: navigationRouter,
            fetchCommentsUseCase: makeFetchCommentsUseCase(),
            postCommentUseCase: makePostCommentUseCase(),
            fetchRepliesUseCase: makeFetchRepliesUseCase(),
            postReplyUseCase: makePostReplyUseCase(),
            commentRepository: commentRepository,
            toggleBlockUseCase: makeToggleBlockUseCase()
        )
        return viewModel
    }

    // MARK: - Views

    func makeCommentView(feedId: Int) -> CommentView {
        return CommentView(viewModel: self.makeCommentViewModel(feedId: feedId))
    }
}
