//
//  FavoriteCodiListView.swift
//  Codive
//
//  Created by 한태빈 on 1/6/26.
//

import SwiftUI

struct FavoriteCodiListView: View {
    @ObservedObject private var navigationRouter: NavigationRouter

    let showHeart: Bool
    
    init(showHeart: Bool, navigationRouter: NavigationRouter) {
        self.showHeart = showHeart
        self.navigationRouter = navigationRouter
    }

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let items: [FavoriteCodiItem] = [
        .init(title: "영화관 데이트"),
        .init(title: "미술관 데이트"),
        .init(title: "영화관 데이트"),
        .init(title: "미술관 데이트"),
        .init(title: "영화관 데이트"),
        .init(title: "미술관 데이트")
    ]

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "최애 코디",
                onBack: { navigationRouter.navigateBack() },
                rightButton: .none
            )

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        FavoriteCodiCardView(
                            title: item.title,
                            showHeart: showHeart,
                            isLiked: item.isLiked
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white)
    }
}

struct FavoriteCodiCardView: View {
    let title: String
    let showHeart: Bool
    let isLiked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .frame(width: 160, height: 160)
                .overlay(alignment: .topTrailing) {
                    if showHeart {
                        Image(isLiked ? "heart_on" : "heart_off")
                            .frame(width: 15, height: 18)
                            .foregroundStyle(Color.Codive.point1)
                            .padding(14)
                    }
                }
                .codiveCardShadow()

            Text(title)
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FavoriteCodiItem: Identifiable {
    let id = UUID()
    let title: String
    var isLiked: Bool = true
}
