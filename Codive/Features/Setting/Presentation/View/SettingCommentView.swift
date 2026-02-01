//
//  SettingCommentView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingCommentView: View {
    @StateObject var vm: MyCommentsViewModel

    var body: some View {
        ZStack {
            if vm.isLoading && vm.items.isEmpty {
                // 1) 로딩만 있는 상태
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = vm.error, vm.items.isEmpty {
                // 2) 에러 + 데이터 없음
                VStack(spacing: 12) {
                    Text(TextLiteral.Setting.loadFailed)
                        .font(.codive_title2)
                    Text(error.localizedDescription)
                        .font(.codive_body2_regular)
                        .foregroundStyle(.secondary)
                    CustomButton(text: TextLiteral.Setting.retry, widthType: .fixed) {
                        Task { await vm.refresh() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.items.isEmpty {
                // 3) 정상인데 리스트가 비어 있음
                SettingsEmptyView(
                    title: TextLiteral.Setting.myCommentsEmpty,
                    message: TextLiteral.Setting.myCommentsEmptyMessage,
                    actionTitle: TextLiteral.Setting.goToFeed
                ) {
                    // 라우팅
                }
            } else {
                // 4) 정상 리스트
                List {
                    ForEach(vm.items) { (comment: MyComment) in
                        VStack(alignment: .leading, spacing: 12) {
                            // 댓글 본문
                            HStack(spacing: 12) {
                                // 프로필 이미지
                                if let avatarURL = comment.author.avatarURL {
                                    AsyncImage(url: avatarURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        case .empty, .failure:
                                            Image(systemName: "person.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundStyle(Color.Codive.grayscale5)
                                        @unknown default:
                                            Color.Codive.grayscale5
                                        }
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(Color.Codive.grayscale5)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text(comment.author.nickname)
                                            .font(.codive_body1_bold)
                                            .foregroundStyle(Color.Codive.grayscale1)

                                        Spacer()

                                        Text(
                                            comment.createdAt.formatted(
                                                date: .numeric,
                                                time: .omitted
                                            )
                                        )
                                        .font(.codive_body2_regular)
                                        .foregroundStyle(Color.Codive.grayscale4)
                                    }

                                    Text(comment.contentPreview)
                                        .font(.codive_body2_regular)
                                        .foregroundStyle(Color.Codive.grayscale1)
                                        .lineLimit(1)
                                }
                            }

                            // 답글 목록
                            if !comment.replies.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(comment.replies) { reply in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("L")
                                                .font(.codive_body2_regular)
                                                .foregroundStyle(Color.Codive.grayscale4)
                                                .frame(width: 16)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(reply.content)
                                                    .font(.codive_body2_regular)
                                                    .foregroundStyle(Color.Codive.grayscale1)
                                                    .lineLimit(2)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 12)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(TextLiteral.Setting.myComments)
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.refresh() }
        .refreshable { await vm.refresh() }
    }
}
