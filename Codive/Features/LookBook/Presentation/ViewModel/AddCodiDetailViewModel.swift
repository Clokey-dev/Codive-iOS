//
//  AddCodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

@MainActor
final class AddCodiDetailViewModel: ObservableObject {
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    
    @Published var products: [ProductItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "전체"
    @Published var selectedProductIds: Set<Int> = []
    
    // 필터링된 상품 리스트
    var filteredProducts: [ProductItem] {
        products.filter { product in
            let matchCategory = (selectedCategory == "전체")
            let matchSearch = searchText.isEmpty ||
                             (product.name?.contains(searchText) ?? false) ||
                             (product.brand?.contains(searchText) ?? false)
            return matchCategory && matchSearch
        }
    }

    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        Task { await fetchProducts() }
    }
    
    func fetchProducts() async {
        do {
            self.products = try await useCase.fetchProductList()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func toggleProductSelection(_ product: ProductItem) {
        if selectedProductIds.contains(product.id) {
            selectedProductIds.remove(product.id)
        } else if selectedProductIds.count < 10 {
            selectedProductIds.insert(product.id)
        }
    }
    
    func handleBackTap() { navigationRouter.navigateBack() }
    func handleComplete() { print("완료") }
}
