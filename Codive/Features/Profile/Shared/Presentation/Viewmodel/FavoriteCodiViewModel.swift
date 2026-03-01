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
    
    private let navigationRouter: NavigationRouter
    private let fetchFavoriteLookBookUseCase: FetchFavoriteLookBookUseCase
    
    init(navigationRouter: NavigationRouter, fetchFavoriteLookBookUseCase: FetchFavoriteLookBookUseCase) {
        self.navigationRouter = navigationRouter
        self.fetchFavoriteLookBookUseCase = fetchFavoriteLookBookUseCase
    }
    
    func loadFavoriteCoordinates() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.favoriteCoordinates = try await fetchFavoriteLookBookUseCase.fetchFavoriteCoordinate(memberId: nil)
        } catch {
            self.errorMessage = "데이터를 불러오는 데 실패했습니다."
            #if DEBUG
            print("[FavoriteCodi] Error fetching favorites: \(error)")
            #endif
        }
        
        isLoading = false
    }
}
