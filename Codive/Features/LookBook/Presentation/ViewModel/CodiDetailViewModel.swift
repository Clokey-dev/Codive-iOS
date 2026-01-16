//
//  CodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

@MainActor
final class CodiDetailViewModel: ObservableObject {
    
    // MARK: - Properties (State: Data)
    
    @Published var codiDetail: CodiDetailEntity?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Properties (State: UI Control)
    
    @Published var showClothSelector: Bool = false
    @Published var selectedIndex: Int?
    @Published var showDeleteAlert: Bool = false
    
    // MARK: - Properties (Dependencies)
    
    private let navigationRouter: NavigationRouter
    private let codiUseCase: CodiUseCase

    /// 현재 조회 중인 코디 ID
    private let codiId: Int

    /// 현재 코디가 속한 룩북 ID (편집 화면 이동 시 컨텍스트 유지용)
    private let lookbookId: Int
    
    // MARK: - Computed Properties
    
    /// 상세 데이터로부터 화면에 표시할 개별 의류 아이템 리스트를 생성합니다.
    var clothItems: [CodiItem] {
        guard let detail = codiDetail else { return [] }
        // TODO: 실제 API 응답 구조에 맞게 브랜드 및 이름 매핑 로직 확인 필요
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
}

// MARK: - API / Data Fetching

extension CodiDetailViewModel {
    
    /// 서버로부터 코디 상세 정보를 가져옵니다.
    func fetchCodiDetail() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.codiDetail = try await codiUseCase.fetchCodiDetail(codiId: codiId)
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
}

// MARK: - UI Logic & Selection

extension CodiDetailViewModel {
    
    /// 의류 선택기(셀렉터) 표시 여부를 토글합니다.
    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
            if !showClothSelector {
                selectedIndex = nil
            }
        }
    }
    
    /// 리스트에서 특정 의류 아이템을 선택합니다.
    func selectCloth(at index: Int) {
        selectedIndex = index
    }
}

// MARK: - Navigation & Actions

extension CodiDetailViewModel {
    
    /// 이전 화면으로 이동합니다.
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    /// 코디 편집 화면으로 이동합니다. (현재 데이터 전달)
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
    
    /// 삭제 확인 알럿을 요청합니다.
    func requestDelete() {
        showDeleteAlert = true
    }
    
    /// 코디 삭제를 실행하고 목록으로 돌아갑니다.
    func deleteCodi() {
        Task {
            // TODO: 실제 서버 삭제 API 호출 로직 추가 (try await codiUseCase.deleteCodi(id: codiId))
            print("DEBUG: 코디 \(codiId) 삭제 요청")
            navigationRouter.navigateBack()
        }
    }
}

// MARK: - Private Helpers

private extension CodiDetailViewModel {
    
    /// 에러 발생 시 처리 및 로깅을 담당합니다.
    func handleError(_ error: Error) {
        print("DEBUG: 코디 상세 로드 실패 - \(error.localizedDescription)")
        self.errorMessage = error.localizedDescription
    }
}
