//
//  CodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

@MainActor
final class CodiDetailViewModel: ObservableObject {
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    let codiId: Int
    
    @Published var codiDetail: CodiDetailEntity?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showClothSelector: Bool = false
    @Published var selectedIndex: Int? = nil
    @Published var showDeleteAlert: Bool = false
    
    var clothItems: [CodiItem] {
        guard let detail = codiDetail else { return [] }
        return [
            CodiItem(id: 1, imageName: detail.topImageURL, brand: "Brand", name: "Top"),
            CodiItem(id: 2, imageName: detail.bottomImageURL, brand: "Brand", name: "Bottom"),
            CodiItem(id: 3, imageName: detail.shoeImageURL, brand: "Brand", name: "Shoes")
        ]
    }
    
    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase, codiId: Int) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.codiId = codiId
    }
    
    func fetchCodiDetail() {
        isLoading = true
        Task {
            do {
                let detail = try await useCase.fetchCodiDetail(codiId: codiId)
                self.codiDetail = detail
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
            if !showClothSelector { selectedIndex = nil }
        }
    }
    
    func selectCloth(at index: Int) { selectedIndex = index }

    // MARK: - Navigation
    func navigateToEditCodi() {
        guard let detail = codiDetail else { return }
        
        let data = SelectedCodi(
            codiId: codiId,
            imageURL: detail.imageURL, name: detail.name,
            memo: detail.memo
        )
        
        // 정의한 editCodi 경로로 이동
        navigationRouter.navigate(to: .editCodi(lookbookId: 0, selectedCodiData: data))
    }
    
    func requestDelete() { showDeleteAlert = true }
    
    func deleteCodi() {
        Task {
            print("코디 \(codiId) 삭제 완료")
            navigationRouter.navigateBack()
        }
    }
    
    func handleBackTap() { navigationRouter.navigateBack() }
}

extension CodiDetailViewModel {
    static var preview: CodiDetailViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = LookBookDataSource()
        let mockRepository = LookBookRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = LookBookUseCase(repository: mockRepository)
        return CodiDetailViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase,
            codiId: 11
        )
    }
}
