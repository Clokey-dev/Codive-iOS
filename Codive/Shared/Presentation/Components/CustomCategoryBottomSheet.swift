//
//  CustomCategorySheet.swift
//  Codive
//

import SwiftUI

struct CustomCategoryBottomSheet: View {
    @State private var selectedCategory: String = "상의"
    @State private var selectedSubcategory: String? = nil

    let categories: [String] = ["상의", "바지", "치마", "아우터", "신발", "가방", "패션소품"]

    let subcategories: [String: [String]] = [
        "상의": ["티셔츠", "니트/스웨터", "맨투맨", "후드티", "반팔티","셔츠/블라우스", "나시", "기타"],
        "바지": ["청바지", "반바지", "트레이닝/조거팬츠", "슈트팬츠/슬랙스", "레깅스", "기타"],
        "치마": ["미니스커트", "미디스커트", "롱스커트", "원피스", "투피스", "기타"],
        "아우터": ["숏패딩/헤비 아우터", "무스탕/퍼", "후드집업", "점퍼/바람막이", "가죽자켓", "청자켓", "슈트/블레이져", "가디건", "아노락" ,"후리스/양털", "코트", "롱패딩", "패딩조끼", "기타"],
        "신발": ["스니커즈", "부츠/워커", "구두", "샌들/슬리퍼", "기타"],
        "가방": ["메신저/크로스백", "숄더백", "백팩", "토트백", "에코백", "기타"],
        "패션소품": ["모자", "머플러", "양말/레그웨어", "시계", "주얼리", "벨트", "선글라스/안경", "기타"]
    ]

    var body: some View {
        VStack(spacing: 0) {

            // 1) 상단 캡슐 + Divider
            Capsule()
                .fill(Color("Grayscale5"))
                .frame(width : 69, height: 4)
                .padding(.top, 9)
                .padding(.bottom, 22)

            Divider() // 상단 구분선

            // 2) 좌·우 컬럼
            HStack(spacing: 0) {

                // 왼쪽
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            selectedCategory = category
                            selectedSubcategory = nil
                        } label: {
                            Text(category)
                                .font(.codive_title3)
                                .foregroundStyle(Color("Grayscale1"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 12)
                                .background(
                                    selectedCategory == category
                                    ? Color("Grayscale5")
                                    : Color("Grayscale7")
                                )
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(width: 100)
                .background(Color("Grayscale7"))

                // 가운데 세로 Divider (좌우 사이 흰 배경 제거)
                Divider() // HStack 안에서는 세로 Divider로 렌더링됨
                    .frame(width: 1) // 얇게 고정(선택사항)

                // 오른쪽(소분류, 스크롤)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(subcategories[selectedCategory] ?? [], id: \.self) { sub in
                            Button {
                                selectedSubcategory = sub
                            } label: {
                                Text(sub)
                                    .font(.codive_title3)
                                    .foregroundStyle(Color("Grayscale1"))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedSubcategory == sub
                                        ? Color("Grayscale5")
                                        : Color("Grayscale7")
                                    )
                            }
                            Divider()
                        }
                    }
                }
            }
        }
        .background(Color("Grayscale7"))
        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
    }
    
}

#Preview {
    CustomCategoryBottomSheet()
        .frame(height: 404)
}
