//
//  CodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

@MainActor
final class CodiDetailViewModel: ObservableObject {
    @Published var coordinatePreview: CoordinatePreviewEntity?
    @Published var coordinateDetails: [CoordinateDetailEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showClothSelector: Bool = false
    @Published var selectedIndex: Int?
    @Published var showDeleteAlert: Bool = false
    @Published var isOverflowMenuExpanded: Bool = false
    
    private let navigationRouter: NavigationRouter
    private let codiUseCase: CodiUseCase
    private let specificLookBookUseCase: SpecificLookBookUseCase
    private let coordinateId: Int64
    
    var clothItems: [CodiItem] {
        coordinateDetails.map {
            CodiItem(
                id: $0.coordinateClothId,
                imageName: $0.imageUrl,
                brand: $0.brand,
                name: $0.name,
                clothId: $0.clothId
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
        coordinateId: Int64
    ) {
        self.navigationRouter = navigationRouter
        self.codiUseCase = codiUseCase
        self.specificLookBookUseCase = specificLookBookUseCase
        self.coordinateId = coordinateId
    }
}

extension CodiDetailViewModel {
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

extension CodiDetailViewModel {
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
    
    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
            if !showClothSelector {
                selectedIndex = nil
            }
        }
    }
    
    func selectCloth(at index: Int) {
        if selectedIndex == index {
            selectedIndex = nil
        } else {
            selectedIndex = index
        }
    }
}

extension CodiDetailViewModel {
    func toggleOverflowMenu() {
        isOverflowMenuExpanded.toggle()
    }
    
    func closeOverflowMenu() {
        isOverflowMenuExpanded = false
    }
    
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func navigateToEditCodi() {
        isOverflowMenuExpanded = false
        guard let preview = coordinatePreview else { return }
        
        let payloads: [Payloads] = coordinateDetails.map { detail in
            
            return Payloads(
                clothId: detail.clothId,
                locationX: detail.locationX,
                locationY: detail.locationY,
                ratio: detail.ratio,
                degree: detail.degree,
                order: detail.order
            )
        }
        
        let data = SelectedCodi(
            coordinateId: coordinateId,
            imageUrl: preview.imageUrl,
            name: preview.coordinateName,
            memo: preview.coordinateMemo,
            payloads: payloads
        )
        
        navigationRouter.navigate(
            to: .editCodi(
                selectedCodiData: data
            )
        )
    }
    
    func requestDelete() {
        isOverflowMenuExpanded = false
        showDeleteAlert = true
    }
    
    func deleteCodi() {
        Task {
            do {
                try await specificLookBookUseCase.deleteCoordinate(
                    coordinateId: coordinateId
                )
                navigationRouter.navigateBack()
            } catch {
                self.errorMessage = TextLiteral.LookBook.alertFailDeleteCoordi
            }
        }
    }
}

private extension CodiDetailViewModel {
    func handleError(_ error: Error) {
        print("DEBUG: 코디 상세 로드 실패 - \(error.localizedDescription)")
        self.errorMessage = error.localizedDescription
    }
}
