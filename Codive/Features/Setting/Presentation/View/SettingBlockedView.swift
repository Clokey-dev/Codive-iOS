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
        VStack(spacing: 0) {
            CustomNavigationBar(title: TextLiteral.Setting.blockedUsers) {
                vm.navigateBack()
            }

            content
                .task { await vm.refresh() }
                .refreshable { await vm.refresh() }
                .alert(
                TextLiteral.Setting.unblockAlertTitle,
                isPresented: $vm.showUnblockAlert
            ) {
                Button(TextLiteral.Common.cancel, role: .cancel) {
                    vm.pendingUnblockUser = nil
                }
                Button(TextLiteral.Common.confirm, role: .destructive) {
                    Task { await vm.confirmUnblock() }
                }
            } message: {
                if let user = vm.pendingUnblockUser {
                    Text(TextLiteral.Setting.unblockAlertMessage(user.user.nickname))
                }
            }
        }
        .navigationBarHidden(true)
        .enableSwipeBack {
            vm.navigateBack()
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.items.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = vm.error, vm.items.isEmpty {
            VStack {
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
            VStack {
                Image("orangeWarning")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.Codive.main2)
                Text(TextLiteral.Setting.blockedUsersEmpty)
                    .font(.codive_title2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(vm.items, id: \.id) { bu in
                CustomUserRow(
                    user: bu.user,
                    buttonTitle: TextLiteral.Setting.unblock,
                    buttonStyle: .secondary
                ) {
                    vm.requestUnblock(user: bu)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
        }
    }
}
