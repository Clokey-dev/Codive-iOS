//
//  LikedRecordsViewModel.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//

import Foundation
import SwiftUI

// 좋아요한 기록
final class LikedRecordsViewModel: ObservableObject {
    @Published private(set) var items: [LikedRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let navigationRouter: NavigationRouter
    private let getLikedUC: GetLikedRecordsUseCase
    private let pageSize: Int

    init(
        navigationRouter: NavigationRouter,
        getLikedUC: GetLikedRecordsUseCase,
        pageSize: Int = 500
    ) {
        self.navigationRouter = navigationRouter
        self.getLikedUC = getLikedUC
        self.pageSize = pageSize
    }

    var isEmpty: Bool { !isLoading && items.isEmpty && error == nil }

    @MainActor
    func refresh() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let data = try await getLikedUC.fetch(page: 1, size: pageSize)
            items = data
        } catch {
            self.error = error
            items = []
        }
    }

    @MainActor
    func navigateToFeedDetail(feedId: Int) {
        navigationRouter.navigate(to: .feedDetail(feedId: feedId))
    }
}
