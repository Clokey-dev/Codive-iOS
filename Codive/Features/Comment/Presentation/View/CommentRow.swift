//
//  CommentRow.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import SwiftUI
import Kingfisher

// MARK: - CommentRow (리스트 아이템)
struct CommentRow: View {
    let comment: Comment
    var isReply: Bool = false
    let replyingToCommentId: Int?
    let onReplyTap: (Int) -> Void
    let onFetchRepliesTap: (Int) -> Void
    let onFetchAllRepliesTap: (Int) -> Void
    let onProfileImageTap: (String, Bool) -> Void
    let onMoreTap: (Comment, CGRect) -> Void

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: 댓글 내용
            HStack(alignment: .top, spacing: 10) {
                // 프로필 이미지
                KFImage(URL(string: comment.author.profileImageUrl ?? ""))
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(
                        width: (isReply ? 28 : 36) * UIScreen.main.scale,
                        height: (isReply ? 28 : 36) * UIScreen.main.scale
                    )))
                    .placeholder {
                        Image("Profile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .onFailure { _ in }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isReply ? 28 : 36, height: isReply ? 28 : 36)
                    .clipShape(Circle())
                .onTapGesture {
                    onProfileImageTap(comment.author.id, comment.isMine)
                }

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

                    if !isReply {
                        Button {
                            onReplyTap(comment.id)
                        } label: {
                            Text(TextLiteral.Comment.addReply)
                                .font(.codive_body3_regular)
                                .foregroundStyle(Color.Codive.grayscale4)
                        }
                        .padding(.top, 4)
                    }

                    // MARK: 답글 더보기/숨기기 버튼
                    let actualReplyCount = comment.replies?.count ?? 0
                    let totalReplyCount = max(comment.replyCount ?? 0, actualReplyCount)

                    if comment.hasReplies || actualReplyCount > 0 {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isExpanded.toggle()
                                if isExpanded && actualReplyCount == 0 {
                                    onFetchRepliesTap(comment.id)
                                }
                            }
                        } label: {
                            if isExpanded {
                                Text(TextLiteral.Comment.hideReplies)
                                    .font(.codive_body2_regular)
                                    .foregroundStyle(Color.Codive.grayscale4)
                            } else {
                                Text(TextLiteral.Comment.repliesCount(totalReplyCount))
                                    .font(.codive_body2_regular)
                                    .foregroundStyle(Color.Codive.grayscale4)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                GeometryReader { proxy in
                    Button(
                        action: {
                            onMoreTap(comment, proxy.frame(in: .named("commentList")))
                        },
                        label: {
                            Image("more")
                                .font(.system(size: 12))
                        }
                    )
                }
                .frame(width: 20, height: 20)
            }
            .padding(.leading, isReply ? 40 : 0)

            // MARK: 답글 리스트
            if isExpanded, let replies = comment.replies {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(replies, id: \.id) { reply in
                        CommentRow(
                            comment: reply,
                            isReply: true,
                            replyingToCommentId: replyingToCommentId,
                            onReplyTap: onReplyTap,
                            onFetchRepliesTap: onFetchRepliesTap,
                            onFetchAllRepliesTap: onFetchAllRepliesTap,
                            onProfileImageTap: onProfileImageTap,
                            onMoreTap: onMoreTap
                        )
                    }

                    // "N개 더보기" 버튼
                    if (replies.count) < (comment.replyCount ?? 0) {
                        let remainingCount = (comment.replyCount ?? 0) - replies.count
                        Button {
                            onFetchAllRepliesTap(comment.id)
                        } label: {
                            Text("\(remainingCount)개 더보기")
                                .font(.codive_body2_regular)
                                .foregroundStyle(Color.Codive.grayscale4)
                        }
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

        let mockOtherProfileRepository = OtherProfileRepositoryImpl(apiService: ProfileAPIService())
        let toggleBlockUseCase = DefaultToggleBlockUseCase(repository: mockOtherProfileRepository)

        let viewModel = CommentViewModel(
            feedId: 1,
            navigationRouter: NavigationRouter(),
            fetchCommentsUseCase: fetchUseCase,
            postCommentUseCase: postUseCase,
            fetchRepliesUseCase: fetchRepliesUseCase,
            postReplyUseCase: postReplyUseCase,
            commentRepository: mockRepository,
            toggleBlockUseCase: toggleBlockUseCase
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
            onFetchAllRepliesTap: { _ in },
            onProfileImageTap: { _, _ in },
            onMoreTap: { _, _ in }
        )
        .previewDisplayName("댓글 아이템")
    }
}
#endif
