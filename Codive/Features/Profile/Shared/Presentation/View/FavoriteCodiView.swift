//
//  FavoriteCodiView.swift
//  Codive
//
//  Created by 한태빈 on 1/15/26.
//

import SwiftUI

struct FavoriteCodiView: View {
    @ObservedObject private var navigationRouter: NavigationRouter
    
    let showHeart: Bool

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    init(showHeart: Bool, navigationRouter: NavigationRouter) {
        self.showHeart = showHeart
        self.navigationRouter = navigationRouter
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "최애 코디",
                onBack: { navigationRouter.navigateBack() },
                rightButton: .none
            )

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 32) {
                    ForEach(0..<8, id: \.self) { idx in
                        CodiCard(
                            imageURL: URL(string: "https://via.placeholder.com/160"),
                            title: idx.isMultiple(of: 2) ? "영화관 데이트" : "미술관 데이트",
                            icon: showHeart ? .heart(isSelected: true, onTap: nil) : .none,
                            cardWidth: 160,
                            imageSize: 160,
                            cornerRadius: 16,
                            iconPadding: 14,
                            iconSize: 20,
                            onCardTap: nil
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

#Preview {
    FavoriteCodiView(showHeart: true, navigationRouter: NavigationRouter())
}
