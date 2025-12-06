//
//  CommentRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation

final class CommentRepositoryImpl: CommentRepository {
    
    private let dataSource: CommentDataSource
    
    init(dataSource: CommentDataSource) {
        self.dataSource = dataSource
    }
    
    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool) {
        return try await dataSource.fetchComments(feedId: feedId, page: page)
    }
    
    func postComment(feedId: Int, content: String) async throws -> Comment {
        return try await dataSource.postComment(feedId: feedId, content: content)
    }
}
