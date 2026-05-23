//
//  FavoriteCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 2/5/26.
//

import Foundation

@MainActor
final class FavoriteCodiViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var favoriteCoordinates: [MyFavoriteLookBookResponseDTO] = []

    @Published var isShowingPopup: Bool = false
    @Published var selectedCoordinatePreview: CoordinatePreviewEntity?
    @Published var selectedCoordinateDetails: [CoordinateDetailEntity] = []

    var popupClothItems: [CodiItem] {
        selectedCoordinateDetails.map { detail in
            CodiItem(
                id: detail.coordinateClothId,
                imageName: detail.imageUrl,
                brand: detail.brand,
                name: detail.name,
                clothId: detail.clothId,
                category: detail.category,
                parentCategory: detail.parentCategory
            )
        }
    }

    var popupPayloads: [Payloads] {
        selectedCoordinateDetails.map { detail in
            Payloads(
                clothId: detail.clothId,
                locationX: detail.locationX,
                locationY: detail.locationY,
                ratio: detail.ratio,
                degree: detail.degree,
                order: detail.order
            )
        }
    }

    private let navigationRouter: NavigationRouter
    private let fetchMyFavoriteLookBookUseCase: FetchMyFavoriteLookBookUseCase
    
    init(navigationRouter: NavigationRouter, fetchMyFavoriteLookBookUseCase: FetchMyFavoriteLookBookUseCase) {
        self.navigationRouter = navigationRouter
        self.fetchMyFavoriteLookBookUseCase = fetchMyFavoriteLookBookUseCase
    }
    
    func loadFavoriteCoordinates(memberId: Int?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let memberId {
                self.favoriteCoordinates = try await fetchMyFavoriteLookBookUseCase.fetchFavoriteCoordinate(memberId: memberId)
            } else {
                self.favoriteCoordinates = try await fetchMyFavoriteLookBookUseCase.fetchMyFavoriteCoordinate()
            }
        } catch {
            self.errorMessage = "데이터를 불러오는 데 실패했습니다."
            #if DEBUG
            print("[FavoriteCodi] Error fetching favorites: \(error)")
            #endif
        }
        
        isLoading = false
    }

    func onCodiCardTapped(coordinateId: Int64) {
        Task {
            do {
                self.selectedCoordinatePreview = try await fetchMyFavoriteLookBookUseCase.fetchCoordinatePreview(coordinateId: coordinateId)
                self.selectedCoordinateDetails = try await fetchMyFavoriteLookBookUseCase.fetchCoordinateDetail(coordinateId: coordinateId)
                self.isShowingPopup = true
            } catch {
                #if DEBUG
                print("[FavoriteCodi] 코디 상세 로드 실패: \(error)")
                #endif
            }
        }
    }
}
