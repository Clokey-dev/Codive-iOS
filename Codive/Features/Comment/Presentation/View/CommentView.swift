//
//  CommentView.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import SwiftUI

struct CommentView: View {
    @StateObject var viewModel: CommentViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            ZStack {
                Text(TextLiteral.Comment.title)
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .padding(.top, 5)
                
                HStack {
                    Spacer()
                    Button(action: { dismiss() }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.Codive.grayscale1)
                    })
                    .padding(.trailing, 25)
                }
            }
            .frame(height: 56)
            
            Divider().overlay(Color.Codive.grayscale6)
            
            // MARK: - Comment List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(viewModel.comments) { comment in
                        CommentRow(comment: comment)
                    }
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 30)
                .padding(.vertical, 24)
            }
            .onAppear {
                viewModel.fetchFirstPage()
            }
            
            // MARK: - Comment Input Area
            VStack(spacing: 0) {
                Divider().overlay(Color.Codive.grayscale6)
                HStack(alignment: .center, spacing: 12) {
                    TextField(TextLiteral.Comment.placeholder, text: $viewModel.currentCommentText)
                        .padding(.horizontal, 15)
                        .frame(height: 40)
                        .background(Color.Codive.main6)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .font(.codive_body2_regular)
                    Button(action: {
                        viewModel.postComment()
                    }, label: {
                        Image("comment_enter")
                            .foregroundStyle(.white)
                            .frame(width: 35, height: 35)
                            .background(Color.Codive.main0)
                            .clipShape(Circle())
                    })
                    .disabled(viewModel.currentCommentText.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .padding(.vertical, 12)
            }
        }
        .background(Color.white)
        .clipShape(
            .rect(
                topLeadingRadius: 20,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20
            )
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - CommentRow (리스트 아이템)
struct CommentRow: View {
    let comment: Comment
    var isReply: Bool = false
    
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: 댓글 내용
            HStack(alignment: .top, spacing: 10) {
                // 프로필 이미지
                AsyncImage(url: URL(string: comment.author.profileImageUrl ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(Color.Codive.grayscale5)
                }
                .frame(width: isReply ? 28 : 36, height: isReply ? 28 : 36)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    // 닉네임
                    Text(comment.author.nickname)
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale1)
                    
                    // 댓글내용
                    Text(comment.content)
                        .font(.codive_body3_regular)
                        .foregroundStyle(Color.Codive.grayscale2)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                    
                    Button(action: {}, label: {
                        Text(TextLiteral.Comment.addReply)
                            .font(.codive_body3_regular)
                            .foregroundStyle(Color.Codive.grayscale4)
                    })
                    .padding(.top, 4)
                    
                    // MARK: 답글 더보기/숨기기 버튼
                    if comment.hasReplies, let replies = comment.replies, !replies.isEmpty {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) { isExpanded.toggle() }
                        }, label: {
                            Text(isExpanded ? TextLiteral.Comment.hideReplies : TextLiteral.Comment.repliesCount(replies.count))
                                .font(.codive_body2_regular)
                                .foregroundStyle(Color.Codive.grayscale4)
                        })
                        .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {}, label: {
                    Image("more")
                        .font(.system(size: 12))
                })
            }
            .padding(.leading, isReply ? 40 : 0)
            
            // MARK: 답글 리스트
            if isExpanded, let replies = comment.replies {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(replies) { reply in
                        CommentRow(comment: reply, isReply: true)
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

// MARK: - Preview
struct CommentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let mockRepository = MockCommentRepository()
        let fetchUseCase = DefaultFetchCommentsUseCase(commentRepository: mockRepository)
        let postUseCase = DefaultPostCommentUseCase(commentRepository: mockRepository)
        
        let viewModel = CommentViewModel(
            feedId: 1,
            fetchCommentsUseCase: fetchUseCase,
            postCommentUseCase: postUseCase
        )
        
        return CommentView(viewModel: viewModel)
            .previewDisplayName("댓글과 답글")
    }
}
