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
                    Text("불러오지 못했어요")
                        .font(.codive_title2)
                    Text(error.localizedDescription)
                        .font(.codive_body2_regular)
                        .foregroundStyle(.secondary)
                    CustomButton(text: "다시 시도", widthType: .fixed) {
                        Task { await vm.refresh() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.items.isEmpty {
                // 3) 정상인데 리스트가 비어 있음
                SettingsEmptyView(
                    title: "아직 남긴 댓글이 없어요!",
                    message: "지금 하나 써볼까요?",
                    actionTitle: "피드로 이동하기"
                ) {
                    // 라우팅
                }
            } else {
                // 4) 정상 리스트
                List {
                    ForEach(vm.items) { (comment: MyComment) in  // 파라미터 타입 명시
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text(comment.author.nickname)
                                    .font(.codive_body1_bold)

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
                                .lineLimit(3)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("내가 남긴 댓글")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.refresh() }
        .refreshable { await vm.refresh() }
    }
}
