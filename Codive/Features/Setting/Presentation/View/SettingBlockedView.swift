//
//  SettingBlockedView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct SettingBlockedView: View {
    @StateObject var vm: BlockedUsersViewModel

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
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundStyle(Color("main2"))
                    Text("차단한 계정이 없어요").font(.codive_title2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
//                List {
//                    ForEach(vm.items) { bu in
//                        HStack(spacing: 12) {
//                            CustomUserRow(user: bu.user)
//                            Spacer()
//                            Button {
//                                Task { await vm.tapUnblock(userId: bu.id) }
//                            } label: {
//                                Text("차단 해제")
//                                    .font(.codive_body2_medium)
//                                    .padding(.horizontal, 12).padding(.vertical, 6)
//                                    .background(Color("main6"))
//                                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }
//                }
//                .listStyle(.plain)
                EmptyView()
            }
        }
        .navigationTitle("차단한 계정")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.refresh() }
        .refreshable { await vm.refresh() }
    }
}
