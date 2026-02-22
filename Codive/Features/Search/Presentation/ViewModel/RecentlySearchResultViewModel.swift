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
    
    @Published var recentSearchTags: [SearchTagEntity] = []
    @Published var showingDeleteAlert: Bool = false
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }
    
    enum RecentlySearchItem: Identifiable {
        case hashTag(title: String)
        case member(imageUrl: String, title: String, subtitle: String)

        var id: UUID {
            UUID()
        }
    }

    @Published var items: [RecentlySearchItem] = [
        .hashTag(title: "드뮤어룩"),
        .member(
            imageUrl: "https://example.com/profile.jpg",
            title: "피크닉좋아",
            subtitle: "hamster12"
        )
    ]
    
    func deleteTag() {
        // TODO: 태그 삭제 로직 구현
    }
    
    func handleDeleteAll() {
        self.showingDeleteAlert = true
    }
    
    func executeDeleteAll() {
        self.recentSearchTags = []
    }
    
    // MARK: - Navigation
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
