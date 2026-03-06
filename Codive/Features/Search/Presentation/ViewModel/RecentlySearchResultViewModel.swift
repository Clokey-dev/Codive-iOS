//
//  RecentlySearchResultViewModel.swift
//  Codive
//
//  Created by 한금준 on 1/29/26.
//

import Foundation

@MainActor
final class RecentlySearchResultViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter

    @Published var recentSearchItems: [RecentSearchItem] = []
    @Published var showingDeleteAlert: Bool = false

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    func loadData() {
        self.recentSearchItems = RecentSearchStorage.load()
    }

    func deleteItem(_ item: RecentSearchItem) {
        RecentSearchStorage.removeItem(item)
        loadData()
    }

    func handleDeleteAll() {
        self.showingDeleteAlert = true
    }

    func executeDeleteAll() {
        RecentSearchStorage.clear()
        self.recentSearchItems = []
    }

    func handleItemTap(_ item: RecentSearchItem) {
        switch item {
        case .keyword(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            RecentSearchStorage.addTerm(trimmed)
            navigationRouter.navigate(to: .searchResult(query: trimmed))
        case .member(let userId, _, _):
            if let id = Int(userId) {
                RecentSearchStorage.addItem(item)
                navigationRouter.navigate(to: .otherProfile(userId: id))
            }
        }
    }

    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
