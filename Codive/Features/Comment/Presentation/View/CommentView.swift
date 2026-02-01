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
    @FocusState private var isTextFieldFocused: Bool

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
                    ForEach(viewModel.comments, id: \.id) { comment in
                        CommentRow(
                            comment: comment,
                            replyingToCommentId: viewModel.replyingToCommentId,
                            onReplyTap: { viewModel.setReplyingTo(commentId: $0) },
                            onFetchRepliesTap: { viewModel.fetchReplies(for: $0) },
                            onFetchAllRepliesTap: { viewModel.fetchAllReplies(for: $0) }
                        )
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
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        // 스크롤을 올릴 때만 (아래에서 위로 드래그) 키보드 닫기
                        if value.translation.height < 0 {
                            isTextFieldFocused = false
                        }
                    }
            )
            .onAppear {
                viewModel.fetchFirstPage()
            }

            // MARK: - Comment Input Area
            VStack(spacing: 0) {
                Divider().overlay(Color.Codive.grayscale6)

                // 대댓글 입력 중이면 표시
                if let replyingCommentId = viewModel.replyingToCommentId,
                   let replyingComment = viewModel.comments.first(where: { $0.id == replyingCommentId }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("@\(replyingComment.author.nickname)")
                                    .font(.codive_body2_medium)
                                    .foregroundStyle(Color.Codive.main0)
                                Text(replyingComment.content)
                                    .font(.codive_body3_regular)
                                    .foregroundStyle(Color.Codive.grayscale2)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.cancelReply()
                            }, label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.Codive.grayscale4)
                            })
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.Codive.grayscale6)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                }

                // 댓글/대댓글 입력 필드
                HStack(alignment: .center, spacing: 12) {
                    TextField(
                        viewModel.replyingToCommentId != nil ? "대댓글 입력..." : TextLiteral.Comment.placeholder,
                        text: viewModel.replyingToCommentId != nil ? $viewModel.currentReplyText : $viewModel.currentCommentText
                    )
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, 15)
                    .frame(height: 40)
                    .background(Color.Codive.main6)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .font(.codive_body2_regular)

                    Button(action: {
                        if viewModel.replyingToCommentId != nil {
                            viewModel.postReply()
                        } else {
                            viewModel.postComment()
                        }
                    }, label: {
                        Image("comment_enter")
                            .foregroundStyle(.white)
                            .frame(width: 35, height: 35)
                            .background(Color.Codive.main0)
                            .clipShape(Circle())
                    })
                    .disabled(
                        viewModel.replyingToCommentId != nil
                        ? viewModel.currentReplyText.isEmpty
                        : viewModel.currentCommentText.isEmpty
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .padding(.top, 12)
            }
            .background(Color.white)
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
    }
}

// MARK: - CommentRow (리스트 아이템)
struct CommentRow: View {
    let comment: Comment
    var isReply: Bool = false
    let replyingToCommentId: Int?
    let onReplyTap: (Int) -> Void
    let onFetchRepliesTap: (Int) -> Void
    let onFetchAllRepliesTap: (Int) -> Void

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: 댓글 내용
            HStack(alignment: .top, spacing: 10) {
                // 프로필 이미지
                AsyncImage(url: URL(string: comment.author.profileImageUrl ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image("Profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: isReply ? 28 : 36, height: isReply ? 28 : 36)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    // 닉네임
                    HStack(spacing: 4) {
                        Text(comment.author.nickname)
                            .font(.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale1)

                        if comment.isMine {
                            Text("(작성자)")
                                .font(.codive_body3_regular)
                                .foregroundStyle(Color.Codive.main0)
                        }
                    }

                    // 댓글내용
                    Text(comment.content)
                        .font(.codive_body3_regular)
                        .foregroundStyle(Color.Codive.grayscale2)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)

                    if !isReply {
                        Button(action: {
                            onReplyTap(comment.id)
                        }, label: {
                            Text(TextLiteral.Comment.addReply)
                                .font(.codive_body3_regular)
                                .foregroundStyle(Color.Codive.grayscale4)
                        })
                        .padding(.top, 4)
                    }

                    // MARK: 답글 더보기/숨기기 버튼
                    let actualReplyCount = comment.replies?.count ?? 0
                    // replyCount가 0이어도 replies가 있으면 actual count 우선
                    let totalReplyCount = max(comment.replyCount ?? 0, actualReplyCount)

                    if comment.hasReplies || actualReplyCount > 0 {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isExpanded.toggle()
                                if isExpanded && actualReplyCount == 0 {
                                    onFetchRepliesTap(comment.id)
                                }
                            }
                        }, label: {
                            if isExpanded {
                                Text(TextLiteral.Comment.hideReplies)
                                    .font(.codive_body2_regular)
                                    .foregroundStyle(Color.Codive.grayscale4)
                            } else {
                                Text(TextLiteral.Comment.repliesCount(totalReplyCount))
                                    .font(.codive_body2_regular)
                                    .foregroundStyle(Color.Codive.grayscale4)
                            }
                        })
                        .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if comment.isMine {
                    Button(action: {}, label: {
                        Image("more")
                            .font(.system(size: 12))
                    })
                }
            }
            .padding(.leading, isReply ? 40 : 0)

            // MARK: 답글 리스트
            if isExpanded, let replies = comment.replies {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(replies.enumerated()), id: \.offset) { _, reply in
                        CommentRow(
                            comment: reply,
                            isReply: true,
                            replyingToCommentId: replyingToCommentId,
                            onReplyTap: onReplyTap,
                            onFetchRepliesTap: onFetchRepliesTap,
                            onFetchAllRepliesTap: onFetchAllRepliesTap
                        )
                    }

                    // "N개 더보기" 버튼
                    if (replies.count) < (comment.replyCount ?? 0) {
                        let remainingCount = (comment.replyCount ?? 0) - replies.count
                        Button(action: {
                            onFetchAllRepliesTap(comment.id)
                        }, label: {
                            Text("\(remainingCount)개 더보기")
                                .font(.codive_body2_regular)
                                .foregroundStyle(Color.Codive.grayscale4)
                        })
                        .padding(.top, 8)
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
        let fetchRepliesUseCase = DefaultFetchRepliesUseCase(commentRepository: mockRepository)
        let postReplyUseCase = DefaultPostReplyUseCase(commentRepository: mockRepository)

        let viewModel = CommentViewModel(
            feedId: 1,
            fetchCommentsUseCase: fetchUseCase,
            postCommentUseCase: postUseCase,
            fetchRepliesUseCase: fetchRepliesUseCase,
            postReplyUseCase: postReplyUseCase
        )

        return CommentView(viewModel: viewModel)
            .previewDisplayName("댓글과 답글")
    }
}

#if DEBUG
// MARK: - CommentRow Preview
struct CommentRow_Previews: PreviewProvider {
    static var previews: some View {
        let mockComment = Comment(
            id: 1,
            content: "좋은 코디네요! 스타일이 정말 멋있습니다.",
            author: User(
                id: "1",
                nickname: "패셔니스타",
                profileImageUrl: nil
            ),
            isMine: false,
            hasReplies: true,
            replies: [
                Comment(
                    id: 2,
                    content: "감사합니다! 피드백 정말 고마워요 😊",
                    author: User(
                        id: "2",
                        nickname: "코디장인",
                        profileImageUrl: nil
                    ),
                    isMine: true,
                    hasReplies: false,
                    replies: []
                )
            ]
        )

        return CommentRow(
            comment: mockComment,
            replyingToCommentId: nil,
            onReplyTap: { _ in },
            onFetchRepliesTap: { _ in },
            onFetchAllRepliesTap: { _ in }
        )
        .previewDisplayName("댓글 아이템")
    }
}
#endif
