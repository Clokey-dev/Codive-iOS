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

    @Published var recentSearchTerms: [String] = []
    @Published var showingDeleteAlert: Bool = false

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    func loadData() {
        self.recentSearchTerms = RecentSearchStorage.load()
    }

    func deleteTerm(_ term: String) {
        RecentSearchStorage.removeTerm(term)
        loadData()
    }

    func handleDeleteAll() {
        self.showingDeleteAlert = true
    }

    func executeDeleteAll() {
        RecentSearchStorage.clear()
        self.recentSearchTerms = []
    }

    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
