//
//  FavoriteCodiView.swift
//  Codive
//
//  Created by 한태빈 on 1/15/26.
//

import SwiftUI

struct FavoriteCodiView: View {
    @ObservedObject private var navigationRouter: NavigationRouter
    @ObservedObject private var viewModel: FavoriteCodiViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    let showHeart: Bool
    let memberId: Int?
    
    init(
        showHeart: Bool,
        memberId: Int? = nil,
        viewModel: FavoriteCodiViewModel,
        navigationRouter: NavigationRouter
    ) {
        self.showHeart = showHeart
        self.memberId = memberId
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._navigationRouter = ObservedObject(wrappedValue: navigationRouter)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: "최애 코디",
                    onBack: { navigationRouter.navigateBack() },
                    rightButton: .none
                )

                ScrollView(showsIndicators: false) {
                    if viewModel.isLoading && viewModel.favoriteCoordinates.isEmpty {
                        ProgressView()
                            .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: columns, spacing: 32) {
                            ForEach(viewModel.favoriteCoordinates, id: \.coordinateId) { coordinate in
                                CodiCard(
                                    imageURL: URL(string: coordinate.imageUrl),
                                    title: coordinate.coordinateName,
                                    icon: .heart(isSelected: true) {},
                                    cardWidth: 160,
                                    imageSize: 160,
                                    cornerRadius: 16,
                                    iconPadding: 14,
                                    iconSize: 20
                                ) {
                                    viewModel.onCodiCardTapped(coordinateId: Int64(coordinate.coordinateId))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    }
                }
            }

            if viewModel.isShowingPopup, let preview = viewModel.selectedCoordinatePreview {
                FavoriteLookBookPopUp(
                    imageUrl: preview.imageUrl,
                    clothItems: viewModel.popupClothItems,
                    payloads: viewModel.popupPayloads
                ) {
                    viewModel.isShowingPopup = false
                }
                .ignoresSafeArea()
                .transition(.opacity.combined(with: .scale))
                .zIndex(1)
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .enableSwipeBack()
        .task {
            await viewModel.loadFavoriteCoordinates(memberId: memberId)
        }
    }
}
