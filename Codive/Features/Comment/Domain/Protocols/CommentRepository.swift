//
//  CommentRepository.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation

/// 댓글 도메인에 대한 데이터 소스 액세스를 정의하는 프로토콜임.
public protocol CommentRepository {
    /// 특정 피드에 달린 댓글 목록을 가져옴.
    /// - Parameters:
    ///   - feedId: 댓글을 조회할 피드의 ID
    ///   - page: 페이지네이션을 위한 페이지 번호
    /// - Returns: `Comment` 배열과 다음 페이지 존재 여부를 포함하는 튜플
    func fetchComments(feedId: Int, page: Int) async throws -> (comments: [Comment], hasNext: Bool)
    
    /// 새로운 댓글을 작성함.
    /// - Parameters:
    ///   - feedId: 댓글을 작성할 피드의 ID
    ///   - content: 댓글 내용
    /// - Returns: 생성된 `Comment` 객체
    @discardableResult
    func postComment(feedId: Int, content: String) async throws -> Comment
}
