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
            subcategories: ["티셔츠", "니트/스웨터", "맨투맨", "후드티", "반팔티", "셔츠/블라우스", "나시", "기타"]
        ),
        CategoryItem(
            id: 2,
            name: "바지",
            subcategories: ["청바지", "반바지", "트레이닝/조거팬츠", "슈트팬츠/슬랙스", "레깅스", "기타"]
        ),
        CategoryItem(
            id: 3,
            name: "치마",
            subcategories: ["미니스커트", "미디스커트", "롱스커트", "원피스", "투피스", "기타"]
        ),
        CategoryItem(
            id: 4,
            name: "아우터",
            subcategories: ["숏패딩/헤비 아우터", "무스탕/퍼", "후드집업", "점퍼/바람막이", "가죽자켓", "청자켓", "슈트/블레이져", "가디건", "아노락", "후리스/양털", "코트", "롱패딩", "패딩조끼", "기타"]
        ),
        CategoryItem(
            id: 5,
            name: "신발",
            subcategories: ["스니커즈", "부츠/워커", "구두", "샌들/슬리퍼", "기타"]
        ),
        CategoryItem(
            id: 6,
            name: "가방",
            subcategories: ["메신저/크로스백", "숄더백", "백팩", "토트백", "에코백", "기타"]
        ),
        CategoryItem(
            id: 7,
            name: "패션소품",
            subcategories: ["모자", "머플러", "양말/레그웨어", "시계", "주얼리", "벨트", "선글라스/안경", "기타"]
        )
    ]

    // MARK: - Helper Methods

    /// ID로 카테고리 조회
    static func category(byId id: Int) -> CategoryItem? {
        return all.first { $0.id == id }
    }

    /// 이름으로 카테고리 조회
    static func category(byName name: String) -> CategoryItem? {
        return all.first { $0.name == name }
    }
}
