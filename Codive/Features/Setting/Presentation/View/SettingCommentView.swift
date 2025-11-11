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
        Group {
            if vm.isLoading && vm.items.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = vm.error, vm.items.isEmpty {
                VStack(spacing: 12) {
                    Text("불러오지 못했어요").font(.codive_title2)
                    Text(error.localizedDescription).font(.codive_body2_regular).foregroundStyle(.secondary)
                    CustomButton(text: "다시 시도", widthType: .fixed) {
                        Task { await vm.refresh() }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.items.isEmpty {
                SettingsEmptyView(
                    title: "아직 남긴 댓글이 없어요!",
                    message: "지금 하나 써볼까요?",
                    actionTitle: "피드로 이동하기",
                    action: { /* 라우팅 */ }
                )
            } else {
//                List(vm.items) { c in
//                    VStack(alignment: .leading, spacing: 6) {
//                        HStack(spacing: 8) {
//                            Text(c.user.nickname).font(.codive_body1_bold)
//                            Spacer()
//                            Text(c.createdAt.formatted(date: .numeric, time: .omitted))
//                                .font(.codive_caption).foregroundStyle(Color("Grayscale4"))
//                        }
//                        Text(c.content)
//                            .font(.codive_body2_regular)
//                            .foregroundStyle(Color("Grayscale1"))
//                            .lineLimit(3)
//                    }
//                    .padding(.vertical, 6)
//                }
//                .listStyle(.plain)
                EmptyView()
            }
        }
        .navigationTitle("내가 남긴 댓글")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.refresh() }
        .refreshable { await vm.refresh() }
    }
}
