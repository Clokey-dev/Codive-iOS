//
//  BlockedUsersViewModel.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//

import Foundation
import SwiftUI

// 차단한 계정
final class BlockedUsersViewModel: ObservableObject {
    @Published private(set) var items: [BlockedUser] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let navigationRouter: NavigationRouter
    private let getBlockedUC: GetBlockedUsersUseCase
    private let unblockUC: UnblockUserUseCase

    init(
        navigationRouter: NavigationRouter,
        getBlockedUC: GetBlockedUsersUseCase,
        unblockUC: UnblockUserUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.getBlockedUC = getBlockedUC
        self.unblockUC = unblockUC
    }

    var isEmpty: Bool { !isLoading && items.isEmpty && error == nil }

    @MainActor
    func refresh() async {
        isLoading = true
        error = nil
        do {
            items = try await getBlockedUC.fetchAll()
        } catch {
            self.error = error
            items = []
        }
        isLoading = false
    }

    @MainActor
    func tapUnblock(userId: UserID) async {
        do {
            try await unblockUC.execute(userId: userId)
            items.removeAll { $0.id == userId }
        } catch {
            self.error = error
        }
    }

}
