//
//  CategoryFavoriteItem.swift
//  Codive
//
//  Presentation 전용 표현 모델. DonutSegment(색상 포함)를 들고 있어
//  SwiftUI에 의존하므로 Presentation 레이어에서 정의한다.
//

import SwiftUI

struct CategoryFavoriteItem: Identifiable, Hashable {
    let id = UUID()
    let parentCategoryId: Int64
    let categoryName: String
    let items: [DonutSegment]
}
