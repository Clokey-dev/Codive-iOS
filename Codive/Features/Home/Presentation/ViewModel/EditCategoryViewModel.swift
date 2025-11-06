//
//  EditCategoryViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

@MainActor
final class EditCategoryViewModel: ObservableObject {
    
    private let navigationRouter: NavigationRouter
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    struct Item: Identifiable, Hashable {
        var id = UUID()
        var title: String
        var count: Int
    }

    @Published var categories: [Item] = [
        Item(title: "상의", count: 0),
        Item(title: "바지", count: 0),
        Item(title: "스커트", count: 0),
        Item(title: "아우터", count: 0),
        Item(title: "신발", count: 0),
        Item(title: "가방", count: 0),
        Item(title: "패션 소품", count: 0)
    ]

    var totalCount: Int { categories.reduce(0) { $0 + $1.count } }

    func resetCounts() {
        for i in categories.indices { categories[i].count = 0 }
    }

    func applyChanges() {
        print("적용하기 tapped")
        categories.forEach { print("\($0.title): \($0.count)") }
    }

    func handleBackTap() {
        navigationRouter.navigateBack()
        print("뒤로가기 tapped")
    }
}
