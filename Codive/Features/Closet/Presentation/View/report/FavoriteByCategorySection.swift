//
//  FavoriteByCategorySection.swift
//  Codive
//
//  Created by 황상환 on 5/5/26.
//

import SwiftUI

struct FavoriteByCategorySection: View {

    let categories: [CategoryFavoriteItem]
    @Binding var showingTooltip: String?
    let onCardTap: (Int64) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ReportSectionHeader(
                title: "카테고리별 최애 아이템",
                tooltip: "코디 결정하기와 기록에서 태그한 옷을 기반으로\n카테고리마다 얼마나 많이 입었는지 보여주는 통계입니다",
                showingTooltip: $showingTooltip
            )

            if !categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories) { item in
                            FavoriteDonutCard(
                                categoryTitle: item.categoryName,
                                segments: item.items
                            )
                            .frame(width: 332, height: 190)
                            .onTapGesture { onCardTap(item.parentCategoryId) }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 2)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("기본 - 카드 여러 장") {
    ScrollView {
        FavoriteByCategorySection(
            categories: [
                CategoryFavoriteItem(
                    parentCategoryId: 1,
                    categoryName: "상의",
                    items: [
                        DonutSegment(value: 45, color: .Codive.point1, payload: "맨투맨"),
                        DonutSegment(value: 30, color: .Codive.point2, payload: "후드티"),
                        DonutSegment(value: 15, color: .Codive.point3, payload: "셔츠"),
                        DonutSegment(value: 10, color: .Codive.grayscale5, payload: "기타")
                    ]
                ),
                CategoryFavoriteItem(
                    parentCategoryId: 2,
                    categoryName: "하의",
                    items: [
                        DonutSegment(value: 60, color: .Codive.point1, payload: "청바지"),
                        DonutSegment(value: 25, color: .Codive.point2, payload: "면바지"),
                        DonutSegment(value: 15, color: .Codive.point3, payload: "반바지")
                    ]
                ),
                CategoryFavoriteItem(
                    parentCategoryId: 5,
                    categoryName: "아우터",
                    items: [
                        DonutSegment(value: 50, color: .Codive.point1, payload: "코트"),
                        DonutSegment(value: 35, color: .Codive.point2, payload: "패딩"),
                        DonutSegment(value: 15, color: .Codive.point3, payload: "자켓")
                    ]
                )
            ],
            showingTooltip: .constant(nil)
        ) { _ in }
    }
    .background(Color.Codive.grayscale7)
}

#Preview("빈 상태") {
    ScrollView {
        FavoriteByCategorySection(
            categories: [],
            showingTooltip: .constant(nil)
        ) { _ in }
    }
    .background(Color.Codive.grayscale7)
}
