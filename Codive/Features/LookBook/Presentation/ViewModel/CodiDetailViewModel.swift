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
    
    func requestDelete() {
        showDeleteAlert = true
    }
    
    // 2. Alert에서 '삭제'를 눌렀을 때 실제 실행될 로직
    func deleteCodi() {
        Task {
            do {
                // 여기에 실제 삭제 API 호출 로직 추가 가능
                // try await useCase.deleteCodi(codiId: codiId)
                print("코디 \(codiId) 삭제 완료")
                navigationRouter.navigateBack() // 삭제 후 뒤로가기
            } catch {
                self.errorMessage = "삭제에 실패했습니다."
            }
        }
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
