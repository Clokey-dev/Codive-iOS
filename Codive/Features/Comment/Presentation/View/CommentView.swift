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
        ZStack {
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
                                onFetchAllRepliesTap: { viewModel.fetchAllReplies(for: $0) },
                                onProfileImageTap: { viewModel.navigateToProfile(userId: $0, isMine: $1) },
                                onMoreTap: { viewModel.toggleMenu(commentId: $0.id) }
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
                            if value.translation.height < 0 {
                                isTextFieldFocused = false
                            }
                            viewModel.dismissMenu()
                        }
                )
                .onAppear {
                    viewModel.dismissAction = {
                        dismiss()
                    }
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

            // MARK: - 더보기 메뉴 오버레이
            if let menuCommentId = viewModel.expandedMenuCommentId,
               let menuComment = viewModel.findComment(by: menuCommentId) {
                ZStack(alignment: .topTrailing) {
                    Color.black
                        .opacity(0.001)
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.dismissMenu()
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    viewModel.dismissMenu()
                                }
                        )

                    // swiftlint:disable trailing_closure
                    if menuComment.isMine {
                        CustomOverflowMenu(
                            menuType: .commentDelete,
                            menuActions: [
                                { viewModel.onDeleteTapped(commentId: menuCommentId) }
                            ],
                            isExpanded: true,
                            showButton: false,
                            onClose: { viewModel.dismissMenu() }
                        )
                        .padding(.trailing, 20)
                        .padding(.top, 80)
                    } else {
                        CustomOverflowMenu(
                            menuType: .report,
                            menuActions: [
                                { viewModel.onReportTapped(commentId: menuCommentId) },
                                { viewModel.onBlockTapped(comment: menuComment) }
                            ],
                            isExpanded: true,
                            showButton: false,
                            onClose: { viewModel.dismissMenu() }
                        )
                        .padding(.trailing, 20)
                        .padding(.top, 80)
                    }
                    // swiftlint:enable trailing_closure
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(10)
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
        .alert("댓글 삭제", isPresented: $viewModel.showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                viewModel.confirmDelete()
            }
        } message: {
            Text("이 댓글을 삭제하시겠습니까?\n삭제된 댓글은 복구할 수 없습니다.")
        }
        .alert("사용자 차단", isPresented: $viewModel.showBlockAlert) {
            Button("취소", role: .cancel) { }
            Button("차단", role: .destructive) {
                viewModel.confirmBlock()
            }
        } message: {
            if let comment = viewModel.pendingBlockComment {
                Text("\(comment.author.nickname)님을 차단하시겠습니까?\n차단된 사용자의 댓글을 더 이상 볼 수 없습니다.")
            }
        }
    }
}
