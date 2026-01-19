//
//  CodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

@MainActor
final class CodiDetailViewModel: ObservableObject {
    
    // MARK: - Dependencies
    
    private let navigationRouter: NavigationRouter
    private let codiUseCase: CodiUseCase

    /// 현재 조회 중인 코디 ID
    let codiId: Int

    /// 현재 코디가 속한 룩북 ID (편집 화면으로 이동 시 컨텍스트 유지)
    let lookbookId: Int
    
    // MARK: - Published State (Data)
    
    @Published var codiDetail: CodiDetailEntity?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published State (UI Control)
    
    @Published var showClothSelector: Bool = false
    @Published var selectedIndex: Int?
    @Published var showDeleteAlert: Bool = false
    
    // MARK: - Computed Properties
    
    var clothItems: [CodiItem] {
        guard let detail = codiDetail else { return [] }
        return [
            CodiItem(id: 1, imageName: detail.topImageURL, brand: "Brand", name: "Top"),
            CodiItem(id: 2, imageName: detail.bottomImageURL, brand: "Brand", name: "Bottom"),
            CodiItem(id: 3, imageName: detail.shoeImageURL, brand: "Brand", name: "Shoes")
        ]
    }
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        codiUseCase: CodiUseCase,
        codiId: Int,
        lookbookId: Int
    ) {
        self.navigationRouter = navigationRouter
        self.codiUseCase = codiUseCase
        self.codiId = codiId
        self.lookbookId = lookbookId
    }
    
    // MARK: - Data Fetching
    
    func fetchCodiDetail() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let detail = try await codiUseCase.fetchCodiDetail(codiId: codiId)
                self.codiDetail = detail
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    // MARK: - Cloth Selection Logic
    
    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
            if !showClothSelector {
                selectedIndex = nil
            }
        }
    }
    
    func selectCloth(at index: Int) {
        selectedIndex = index
    }
    
    // MARK: - Navigation
    
    func navigateToEditCodi() {
        guard let detail = codiDetail else { return }
        
        let data = SelectedCodi(
            codiId: codiId,
            imageURL: detail.imageURL,
            name: detail.name,
            memo: detail.memo
        )
        
        navigationRouter.navigate(
            to: .editCodi(
                lookbookId: lookbookId,
                selectedCodiData: data
            )
        )
    }
    
    func requestDelete() {
        showDeleteAlert = true
    }
    
    func deleteCodi() {
        Task {
            print("코디 \(codiId) 삭제 완료")
            navigationRouter.navigateBack()
        }
    }
    
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
