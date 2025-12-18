//
//  CodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

@MainActor
final class CodiDetailViewModel: ObservableObject {
    // MARK: - Properties
    private let navigationRouter: NavigationRouter
    private let useCase: LookBookUseCase
    let codiId: Int

    @Published var codiDetail: CodiDetailEntity?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showClothSelector: Bool = false
    @Published var selectedIndex: Int? = nil

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
    init(navigationRouter: NavigationRouter, useCase: LookBookUseCase, codiId: Int) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.codiId = codiId
    }

    func fetchCodiDetail() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let detail = try await useCase.fetchCodiDetail(codiId: codiId)
                self.codiDetail = detail
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    func selectCloth(at index: Int) {
        selectedIndex = index
    }

    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
            if !showClothSelector {
                selectedIndex = nil
            }
        }
    }

    // MARK: - Navigation
    func navigateToEditCodi() {
        print("코디 수정")
    }

    func deleteCodi() {
        print("코디 삭제")
    }

    func handleBackTap() {
        navigationRouter.navigateBack()
    }
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
