//
//  CommentViewModel.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import Foundation
import Combine

@MainActor
final class CommentViewModel: ObservableObject {
    
    // MARK: - Properties
    
    // 댓글 목록
    @Published var comments: [Comment] = []
    
    // 현재 댓글 입력 텍스트
    @Published var currentCommentText: String = ""
    
    // 댓글 로딩 상태
    @Published var isLoading: Bool = false
    
    // 다음 페이지 존재 여부
    @Published var hasNextPage: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    private let feedId: Int
    private let commentRepository: CommentRepository
    
    // MARK: - Initializer
    
    init(
        feedId: Int,
        commentRepository: CommentRepository
    ) {
        self.feedId = feedId
        self.commentRepository = commentRepository
    }
    
    // MARK: - Public Methods
    
    func fetchFirstPage() {
        guard !isLoading, hasNextPage else { return }
        isLoading = true
        
        Task {
            do {
                let result = try await commentRepository.fetchComments(feedId: feedId, page: 0)
                self.comments = result.comments
                self.hasNextPage = result.hasNext
            } catch {
                // TODO: 에러 처리
                print("Error fetching comments: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func fetchNextPage() {
        // TODO: 다음 페이지 로딩 구현 (페이지네이션)
    }
    
    func postComment() {
        guard !currentCommentText.isEmpty else { return }
        
        Task {
            do {
                let newComment = try await commentRepository.postComment(feedId: feedId, content: currentCommentText)
                self.comments.insert(newComment, at: 0)
                self.currentCommentText = ""
            } catch {
                // TODO: 에러 처리
                print("Error posting comment: \(error)")
            }
        }
    }
}
