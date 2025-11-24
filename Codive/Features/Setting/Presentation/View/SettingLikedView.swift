//
//  SettingLikedView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingLikedView: View {
    @StateObject var vm: LikedRecordsViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

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
                    title: "좋아요 한 기록이 없어요!",
                    message: "마음에 드는 기록을 찾아볼까요?",
                    actionTitle: "피드로 이동하기"
                ) {
                    /* 라우팅 */
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(vm.items) { item in      // ← 여기만 ForEach로
                            AsyncImage(url: item.thumbnailURL) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                case .empty:
                                    Color.Codive.main6
                                case .failure:
                                    Color.Codive.main6
                                @unknown default:
                                    Color.Codive.main6
                                }
                            }
                            .frame(height: 110)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                // 게시글 상세로 이동 등
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
        }
        .navigationTitle("좋아요 한 기록")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.refresh() }
        .refreshable { await vm.refresh() }
    }
}
