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
        content
            .navigationTitle("차단한 계정")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.refresh() }
            .refreshable { await vm.refresh() }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.items.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = vm.error, vm.items.isEmpty {
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
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.Codive.main2)
                Text("차단한 계정이 없어요")
                    .font(.codive_title2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(vm.items, id: \.id) { bu in
                CustomUserRow(
                    user: bu.user,
                    buttonTitle: "차단 해제"
                ) {
                    Task { await vm.tapUnblock(userId: bu.id) }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
    }
}
