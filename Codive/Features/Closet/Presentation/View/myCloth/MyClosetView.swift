//
//  MyClosetView.swift
//  Codive
//
//  Created by 황상환 on 12/20/25.
//

import SwiftUI

struct MyClosetView: View {
    @State private var searchText: String = ""
    @State private var selectedMainCategory: String = "전체"
    @State private var selectedSubCategory: String = ""
    
    // 3열 그리드 레이아웃 (여백 없음)
    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // --- 상단 고정 영역 ---
            VStack(spacing: 0) {
                // 네비게이션 바
                CustomNavigationBar(title: "옷장 전체") {
                    print("Back")
                }
                
                // 검색바
                CustomSearchBar(text: $searchText, type: .normal)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                
                // 대분류 카테고리 탭 (좌우 스크롤)
                mainCategoryTab
                
                // 하위 카테고리 (좌우 스크롤로 변경 및 색상 적용)
                if selectedMainCategory != "전체" {
                    subCategorySection
                }
                
                // 정보 바
                infoBar
            }
            .background(Color.white)
            
            // --- 옷 리스트 그리드 영역 ---
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<15, id: \.self) { _ in
                        CustomClothCard(
                            imageName: "sampleCloth",
                            brand: "나이키",
                            title: "Cable knit cardigan navy blue"
                        ) {
                            print("Card Tapped")
                        }
                    }
                }
            }
        }
        .background(Color.white)
    }
    
    // MARK: - Subviews
    
    // 상위 카테고리 탭
    private var mainCategoryTab: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.Codive.grayscale6)
                .frame(height: 1)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    categoryTabItem(name: "전체")
                    ForEach(CategoryConstants.all, id: \.name) { item in
                        categoryTabItem(name: item.name)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder
    private func categoryTabItem(name: String) -> some View {
        VStack(spacing: 12) {
            Text(name)
                .font(.codive_body1_medium)
                .foregroundStyle(selectedMainCategory == name ? Color.Codive.grayscale1 : Color.Codive.grayscale3)
            
            Rectangle()
                .fill(selectedMainCategory == name ? Color.Codive.point1 : Color.clear)
                .frame(height: 2)
        }
        .onTapGesture {
            selectedMainCategory = name
            // 대분류 변경 시 첫 번째 하위 카테고리 자동 선택 로직
            if let firstSub = CategoryConstants.all.first(where: { $0.name == name })?.subcategories.first {
                selectedSubCategory = firstSub
            }
        }
    }
    
    // 하위 카테고리 섹션
    private var subCategorySection: some View {
        let subcategories = CategoryConstants.all.first(where: { $0.name == selectedMainCategory })?.subcategories ?? []
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(subcategories, id: \.self) { sub in
                    Text(sub)
                        .font(.codive_body2_medium)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.white)
                        .foregroundStyle(selectedSubCategory == sub ? Color.Codive.point1 : Color.Codive.grayscale1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedSubCategory == sub ? Color.Codive.point1 : Color.Codive.grayscale6, lineWidth: 1)
                        )
                        .contentShape(Rectangle()) // 터치 영역 확보
                        .onTapGesture {
                            selectedSubCategory = sub
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 2)
        }
        .padding(.top, 10)
    }
    
    private var infoBar: some View {
        HStack {
            Text("총 32개")
                .font(.codive_body3_regular)
                .foregroundStyle(Color.Codive.grayscale3)
            Spacer()
            HStack(spacing: 8) {
                Text("계절 필터")
                Image(systemName: "line.3.horizontal.decrease")
                Text("|")
                    .foregroundStyle(Color.Codive.grayscale6)
                Button("편집") { }
            }
            .font(.codive_body3_regular)
            .foregroundStyle(Color.Codive.grayscale1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    MyClosetView()
}
