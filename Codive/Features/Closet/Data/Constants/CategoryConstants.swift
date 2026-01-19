//
//  CategoryConstants.swift
//  Codive
//
//  Created by 황상환 on 10/9/25.
//

import Foundation

struct CategoryConstants {

    static let all: [CategoryItem] = [
        CategoryItem(
            id: 1,
            name: "상의",
            subcategories: [
                SubcategoryItem(id: 8, name: "티셔츠"),
                SubcategoryItem(id: 9, name: "니트/스웨터"),
                SubcategoryItem(id: 10, name: "맨투맨"),
                SubcategoryItem(id: 11, name: "후드티"),
                SubcategoryItem(id: 12, name: "셔츠/블라우스"),
                SubcategoryItem(id: 13, name: "반팔티"),
                SubcategoryItem(id: 14, name: "나시"),
                SubcategoryItem(id: 15, name: "기타")
            ]
        ),
        CategoryItem(
            id: 2,
            name: "바지",
            subcategories: [
                SubcategoryItem(id: 16, name: "청바지"),
                SubcategoryItem(id: 17, name: "반바지"),
                SubcategoryItem(id: 18, name: "트레이닝/조거팬츠"),
                SubcategoryItem(id: 19, name: "면바지"),
                SubcategoryItem(id: 20, name: "슈트팬츠/슬랙스"),
                SubcategoryItem(id: 21, name: "레깅스"),
                SubcategoryItem(id: 22, name: "기타")
            ]
        ),
        CategoryItem(
            id: 3,
            name: "스커트",
            subcategories: [
                SubcategoryItem(id: 23, name: "미니스커트"),
                SubcategoryItem(id: 24, name: "미디스커트"),
                SubcategoryItem(id: 25, name: "롱스커트"),
                SubcategoryItem(id: 26, name: "원피스"),
                SubcategoryItem(id: 27, name: "투피스"),
                SubcategoryItem(id: 28, name: "기타")
            ]
        ),
        CategoryItem(
            id: 4,
            name: "아우터",
            subcategories: [
                SubcategoryItem(id: 29, name: "숏패딩/헤비 아우터"),
                SubcategoryItem(id: 30, name: "무스탕/퍼"),
                SubcategoryItem(id: 31, name: "후드집업"),
                SubcategoryItem(id: 32, name: "점퍼/바람막이"),
                SubcategoryItem(id: 33, name: "가죽자켓"),
                SubcategoryItem(id: 34, name: "청자켓"),
                SubcategoryItem(id: 35, name: "슈트/블레이저"),
                SubcategoryItem(id: 36, name: "가디건"),
                SubcategoryItem(id: 37, name: "아노락"),
                SubcategoryItem(id: 38, name: "후리스/양털"),
                SubcategoryItem(id: 39, name: "코트"),
                SubcategoryItem(id: 40, name: "롱패딩"),
                SubcategoryItem(id: 41, name: "패딩조끼"),
                SubcategoryItem(id: 42, name: "기타")
            ]
        ),
        CategoryItem(
            id: 5,
            name: "신발",
            subcategories: [
                SubcategoryItem(id: 43, name: "스니커즈"),
                SubcategoryItem(id: 44, name: "부츠/워커"),
                SubcategoryItem(id: 45, name: "구두"),
                SubcategoryItem(id: 46, name: "샌들/슬리퍼"),
                SubcategoryItem(id: 47, name: "기타")
            ]
        ),
        CategoryItem(
            id: 6,
            name: "가방",
            subcategories: [
                SubcategoryItem(id: 48, name: "메신저/크로스백"),
                SubcategoryItem(id: 49, name: "숄더백"),
                SubcategoryItem(id: 50, name: "백팩"),
                SubcategoryItem(id: 51, name: "토트백"),
                SubcategoryItem(id: 52, name: "에코백"),
                SubcategoryItem(id: 53, name: "기타")
            ]
        ),
        CategoryItem(
            id: 7,
            name: "패션 소품",
            subcategories: [
                SubcategoryItem(id: 54, name: "모자"),
                SubcategoryItem(id: 55, name: "머플러"),
                SubcategoryItem(id: 56, name: "양말/레그웨어"),
                SubcategoryItem(id: 57, name: "시계"),
                SubcategoryItem(id: 58, name: "주얼리"),
                SubcategoryItem(id: 59, name: "벨트"),
                SubcategoryItem(id: 60, name: "선글라스/안경"),
                SubcategoryItem(id: 61, name: "기타")
            ]
        )
    ]

    // MARK: - Helper Methods

    /// ID로 상위 카테고리 조회
    static func category(byId id: Int) -> CategoryItem? {
        return all.first { $0.id == id }
    }

    /// 이름으로 상위 카테고리 조회
    static func category(byName name: String) -> CategoryItem? {
        return all.first { $0.name == name }
    }

    /// 하위 카테고리 ID로 상위 카테고리 조회
    static func category(bySubcategoryId id: Int) -> CategoryItem? {
        return all.first { category in
            category.subcategories.contains { $0.id == id }
        }
    }

    /// 하위 카테고리 ID로 하위 카테고리 조회
    static func subcategory(byId id: Int) -> SubcategoryItem? {
        for category in all {
            if let subcategory = category.subcategories.first(where: { $0.id == id }) {
                return subcategory
            }
        }
        return nil
    }

    /// 하위 카테고리 이름으로 하위 카테고리 조회 (상위 카테고리 내에서)
    static func subcategory(byName name: String, in category: CategoryItem) -> SubcategoryItem? {
        return category.subcategories.first { $0.name == name }
    }
}
