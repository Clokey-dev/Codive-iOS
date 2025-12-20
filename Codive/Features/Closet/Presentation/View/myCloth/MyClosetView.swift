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
    @State private var selectedSeasons: Set<Season> = []
    @State private var isShowingSeasonSheet: Bool = false
    
    @State private var isEditMode: Bool = false
    @State private var selectedItemIds: Set<Int> = []
    
    @Namespace private var categoryAnimation
    
    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: isEditMode ? "옷장 편집" : "옷장 전체",
                    onBack: {
                        if isEditMode {
                            isEditMode = false
                            selectedItemIds.removeAll()
                        }
                    },
                    rightButton: isEditMode ? .text(
                        title: "삭제",
                        isEnabled: !selectedItemIds.isEmpty,
                        action: {
                            print("\(selectedItemIds.count)개 삭제")
                            isEditMode = false
                            selectedItemIds.removeAll()
                        }
                    ) : .none
                )
                
                CustomSearchBar(text: $searchText, type: .normal)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                
                mainCategoryTab
                
                if selectedMainCategory != "전체" {
                    subCategorySection
                }
                
                infoBar
            }
            .background(Color.white)
            
            ScrollView {
                let items: [Int] = []

                if items.isEmpty {
                    EmptyStateView(
                        headerTitle: nil,
                        title: "해당 계절 옷이 없어요.",
                        description: "계절에 맞는 옷을 채워넣어보세요.\n디지털 옷장에서 쉽게 관리할 수 있어요.",
                        buttonText: "옷 추가하기",
                        action: {
                            // 옷 추가 액션 연결
                        }
                    )
                    .padding(.top, 150)
                } else {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(items, id: \.self) { idx in
                            CustomClothCard(
                                imageName: "sampleCloth",
                                brand: "나이키",
                                title: "Cable knit cardigan navy blue",
                                isEditMode: isEditMode,
                                isSelected: selectedItemIds.contains(idx)
                            ) {
                                if isEditMode {
                                    if selectedItemIds.contains(idx) {
                                        selectedItemIds.remove(idx)
                                    } else {
                                        selectedItemIds.insert(idx)
                                    }
                                } else {
                                    print("\(idx)번 상세 이동")
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .sheet(isPresented: $isShowingSeasonSheet) {
            CustomSeasonSheet(
                initialSelected: selectedSeasons,
                onClose: { isShowingSeasonSheet = false },
                onApply: { seasons in
                    selectedSeasons = seasons
                    isShowingSeasonSheet = false
                }
            )
            .presentationDetents([.height(358)])
            .presentationDragIndicator(.hidden)
        }
    }
    
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
        let isSelected = selectedMainCategory == name
        
        VStack(spacing: 12) {
            Text(name)
                .font(.codive_body1_medium)
                .foregroundStyle(isSelected ? Color.Codive.grayscale1 : Color.Codive.grayscale3)
            
            ZStack {
                if isSelected {
                    Rectangle()
                        .fill(Color.Codive.point1)
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "underline", in: categoryAnimation)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedMainCategory = name
                if let firstSub = CategoryConstants.all.first(where: { $0.name == name })?.subcategories.first {
                    selectedSubCategory = firstSub
                }
            }
        }
    }
    
    private var subCategorySection: some View {
        let subcategories = CategoryConstants.all.first(where: { $0.name == selectedMainCategory })?.subcategories ?? []
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedSubCategory = sub
                            }
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
                // 필터 버튼과 구분선을 하나의 그룹으로 묶고 투명도로 제어
                HStack(spacing: 8) {
                    Button {
                        isShowingSeasonSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(seasonFilterText)
                                .font(.codive_body3_regular)
                                .foregroundStyle(selectedSeasons.isEmpty ? Color.Codive.grayscale1 : Color("main1"))
                            
                            Image(selectedSeasons.isEmpty ? "filter" : "filter_brown")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text("|")
                        .foregroundStyle(Color.Codive.grayscale6)
                }
                .opacity(isEditMode ? 0 : 1) // 편집 모드일 때 투명하게 (공간은 유지)
                .disabled(isEditMode)      // 클릭 방지
                
                Button(isEditMode ? "취소" : "편집") {
                    withAnimation {
                        isEditMode.toggle()
                        if !isEditMode { selectedItemIds.removeAll() }
                    }
                }
                .font(.codive_body3_regular)
                .foregroundStyle(Color.Codive.grayscale1)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
    }
    
    private var seasonFilterText: String {
        if selectedSeasons.isEmpty {
            return "계절 필터"
        } else {
            let orderedSeasons: [Season] = [.spring, .summer, .fall, .winter]
            let selectedList = orderedSeasons.filter { selectedSeasons.contains($0) }
            return selectedList.map { $0.displayName }.joined(separator: ", ")
        }
    }
}

#Preview {
    MyClosetView()
}
