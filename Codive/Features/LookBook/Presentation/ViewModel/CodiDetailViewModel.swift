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
    
    @Published var coordinatePreview: CoordinatePreviewEntity?
    @Published var coordinateDetails: [CoordinateDetailEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Properties (State: UI Control)
    
    @Published var showClothSelector: Bool = false
    @Published var selectedIndex: Int?
    @Published var showDeleteAlert: Bool = false
    
    // MARK: - Properties (Dependencies)
    
    private let navigationRouter: NavigationRouter
    private let codiUseCase: CodiUseCase
    private let specificLookBookUseCase: SpecificLookBookUseCase

    /// 현재 조회 중인 코디 ID
    private let coordinateId: Int64

    /// 현재 코디가 속한 룩북 ID (편집 화면 이동 시 컨텍스트 유지용)
    private let lookbookId: Int
    
    // MARK: - Computed Properties
    
    /// 상세 데이터로부터 화면에 표시할 개별 의류 아이템 리스트를 생성합니다.
    var clothItems: [CodiItem] {
        coordinateDetails.map {
            CodiItem(
                id: $0.coordinateClothId,
                imageName: $0.imageUrl,
                brand: $0.brand,
                name: $0.name
            )
        }
    }
    
    var selectedDetail: CoordinateDetailEntity? {
        guard let index = selectedIndex,
              index < coordinateDetails.count else { return nil }
        return coordinateDetails[index]
    }
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        codiUseCase: CodiUseCase,
        specificLookBookUseCase: SpecificLookBookUseCase,
        coordinateId: Int64,
        lookbookId: Int
    ) {
        self.navigationRouter = navigationRouter
        self.codiUseCase = codiUseCase
        self.specificLookBookUseCase = specificLookBookUseCase
        self.coordinateId = coordinateId
        self.lookbookId = lookbookId
    }
}

// MARK: - API / Data Fetching

extension CodiDetailViewModel {
    /// 코디 프리뷰 조회
    func fetchCoordinatePreview() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                self.coordinatePreview =
                    try await codiUseCase.fetchCoordinatePreview(
                        coordinateId: coordinateId
                    )
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
}

// MARK: - UI Logic & Selection

extension CodiDetailViewModel {
    
    /// 코디 디테일 조회
    func fetchCoordinateDetail() {
        Task {
            do {
                let details = try await codiUseCase.fetchCoordinateDetail(
                    coordinateId: coordinateId
                )
                self.coordinateDetails = details
            } catch {
                handleError(error)
            }
        }
    }
    
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
        // 이미 선택된 것을 다시 누르면 해제, 아니면 선택
        if selectedIndex == index {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
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
        guard let detail = coordinatePreview else { return }
        
        let data = SelectedCodi(
            codiId: Int(coordinateId),
            imageURL: detail.imageUrl,
            name: detail.coordinateName,
            memo: detail.coordinateMemo
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
            do {
                try await specificLookBookUseCase.deleteCoordinate(
                    coordinateId: coordinateId
                )
                navigationRouter.navigateBack()
            } catch {
                self.errorMessage = "코디 삭제에 실패했습니다."
            }
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
