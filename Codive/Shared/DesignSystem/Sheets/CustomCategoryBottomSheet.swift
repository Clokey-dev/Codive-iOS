//
//  CustomCategorySheet.swift
//  Codive
//
//  Created by 한태빈 on 10/6/25.
//

import SwiftUI

struct CustomCategoryBottomSheet: View {

    /// 외부에서 주입받는 전체 카테고리 데이터
    let allCategories: [CategoryItem]

    /// 현재 선택된 주 카테고리를 외부와 동기화
    @Binding var selectedCategory: CategoryItem?

    /// 최종 선택 완료 시 호출될 클로저
    let onApply: (CategoryItem, String) -> Void

    /// 뷰 내부에서만 사용할 선택된 서브 카테고리 상태
    @State private var selectedSubcategory: String?

    /// 초기 선택된 서브 카테고리 (뷰 초기화 시 전달)
    let initialSubcategory: String?

    var body: some View {
        VStack(spacing: 0) {
            // 1) 상단 캡슐 + Divider
            Capsule()
                .fill(Color("Grayscale5"))
                .frame(width: 69, height: 4)
                .padding(.top, 9)
                .padding(.bottom, 22)

            Divider()
                .foregroundStyle(Color("Grayscale5"))
            
            // 2) 좌·우 컬럼
            HStack(spacing: 0) {
                // 왼쪽 (주 카테고리)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(allCategories) { category in
                            Button {
                                selectedCategory = category
                                selectedSubcategory = nil
                            } label: {
                                Text(category.name)
                                    .font(.codive_title3)
                                    .foregroundStyle(Color("Grayscale1"))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedCategory == category
                                        ? Color("Grayscale6")
                                        : Color.white
                                    )
                            }
                        }
                    }
                }
                .frame(width: 100)
                .background(Color.white)

                // 가운데 세로 Divider
                Divider()
                    .frame(width: 1)
                    .foregroundStyle(Color("Grayscale5"))
                
                // 오른쪽 (하위 카테고리, 스크롤)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(selectedCategory?.subcategories ?? [], id: \.self) { sub in
                            Button {
                                selectedSubcategory = sub
                                if let category = selectedCategory {
                                    onApply(category, sub)
                                }
                            } label: {
                                Text(sub)
                                    .font(.codive_title3)
                                    .foregroundStyle(Color("Grayscale1"))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedSubcategory == sub
                                        ? Color("Grayscale6")
                                        : Color.white
                                    )
                            }
                            Divider()
                        }
                    }
                }
                .background(Color.white)
            }
        }
        .background(Color.white) // First background
        .clipShape(
            .rect(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24
            )
        )
        .background( // Second background
            Color.white
                .ignoresSafeArea(edges: .bottom)
        )
        .onAppear {
            // 뷰가 나타날 때, 만약 외부에서 선택된 카테고리가 없다면 첫 번째 항목을 기본값으로 설정
            if selectedCategory == nil {
                selectedCategory = allCategories.first
            }
            // 초기 서브카테고리 설정
            if let initialSubcategory = initialSubcategory {
                selectedSubcategory = initialSubcategory
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedCategory: CategoryItem? = CategoryConstants.all.first
        
        var body: some View {
            VStack {
                if let category = selectedCategory {
                    Text("선택: \(category.name)")
                }
                
                Spacer()
                
                CustomCategoryBottomSheet(
                    allCategories: CategoryConstants.all,
                    selectedCategory: $selectedCategory,
                    onApply: { mainCategory, subCategory in
                        print("최종 선택 완료: \(mainCategory.name) -> \(subCategory)")
                    },
                    initialSubcategory: nil
                )
                .frame(height: 404)
            }
        }
    }
    
    return PreviewWrapper()
}
