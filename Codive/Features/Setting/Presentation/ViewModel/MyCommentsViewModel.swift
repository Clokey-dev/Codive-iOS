//
//  MyCommentsViewModel.swift
//  Codive
//
//  Created by 한태빈 on 11/11/25.
//

import Foundation
import SwiftUI

final class MyCommentsViewModel: ObservableObject {
    @Published private(set) var items: [MyComment] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let navigationRouter: NavigationRouter
    private let getCommentsUC: GetMyCommentsUseCase
    private let pageSize: Int
    
    init(
        navigationRouter: NavigationRouter,
        getCommentsUC: GetMyCommentsUseCase,
        pageSize: Int = 500
    ) {
        self.navigationRouter = navigationRouter
        self.getCommentsUC = getCommentsUC
        self.pageSize = pageSize
    }
    
    var isEmpty: Bool { !isLoading && items.isEmpty && error == nil }
    
    @MainActor
    func refresh() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let data = try await getCommentsUC.fetch(page: 1, size: pageSize)
            items = data
        } catch {
            self.error = error
            items = []
        }
    }
}
