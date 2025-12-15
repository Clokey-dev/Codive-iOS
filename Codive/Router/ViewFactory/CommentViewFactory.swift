//
//  CommentViewFactory.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import SwiftUI

@MainActor
final class CommentViewFactory {
    // MARK: - Properties
    private weak var commentDIContainer: CommentDIContainer?
    
    // MARK: - Initializer
    init(commentDIContainer: CommentDIContainer) {
        self.commentDIContainer = commentDIContainer
    }
    
    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        if let commentDIContainer {
            switch destination {
            case .comment(let feedId):
                commentDIContainer.makeCommentView(feedId: feedId)
            default:
                EmptyView()
            }
        }
    }
}
