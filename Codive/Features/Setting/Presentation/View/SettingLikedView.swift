//
//  SettingLikedView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingLikedView: View {
    @StateObject var vm: LikedRecordsViewModel

    var body: some View {
        GeometryReader { geometry in
            Group {
                if vm.isLoading && vm.items.isEmpty {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = vm.error, vm.items.isEmpty {
                    VStack(spacing: 12) {
                        Text(TextLiteral.Setting.loadFailed).font(.codive_title2)
                        Text(error.localizedDescription).font(.codive_body2_regular).foregroundStyle(.secondary)
                        CustomButton(text: TextLiteral.Setting.retry, widthType: .fixed) {
                            Task { await vm.refresh() }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.items.isEmpty {
                    SettingsEmptyView(
                        title: TextLiteral.Setting.likedRecordsEmpty,
                        message: TextLiteral.Setting.likedRecordsEmptyMessage,
                        actionTitle: TextLiteral.Setting.goToFeed
                    ) {
                        /* 라우팅 */
                    }
                } else {
                    let itemWidth = geometry.size.width / 3
                    let itemHeight = itemWidth * 4 / 3

                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.fixed(itemWidth), spacing: 0),
                                GridItem(.fixed(itemWidth), spacing: 0),
                                GridItem(.fixed(itemWidth), spacing: 0)
                            ],
                            spacing: 0
                        ) {
                            ForEach(vm.items) { item in
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
                                .frame(width: itemWidth, height: itemHeight)
                                .clipped()
                                .onTapGesture {
                                    // 게시글 상세로 이동
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(TextLiteral.Setting.likedRecords)
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.refresh() }
            .refreshable { await vm.refresh() }
        }
    }
}
