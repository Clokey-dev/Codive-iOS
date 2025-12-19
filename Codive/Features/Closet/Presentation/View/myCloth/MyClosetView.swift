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
    
    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                CustomNavigationBar(title: "옷장 전체") { }
                
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
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<15, id: \.self) { _ in
                        CustomClothCard(
                            imageName: "sampleCloth",
                            brand: "나이키",
                            title: "Cable knit cardigan navy blue"
                        )
                    }
                }
            }
        }
        .background(Color.white)
        .sheet(isPresented: $isShowingSeasonSheet) {
            CustomSeasonSheet(
                initialSelected: selectedSeasons,
                onClose: {
                    isShowingSeasonSheet = false
                },
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
            if let firstSub = CategoryConstants.all.first(where: { $0.name == name })?.subcategories.first {
                selectedSubCategory = firstSub
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
                
                Button("편집") { }
                    .font(.codive_body3_regular)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var seasonFilterText: String {
        if selectedSeasons.isEmpty {
            return "계절 필터"
        } else {
            let orderedSeasons: [Season] = [.spring, .summer, .fall, .winter]
            return orderedSeasons
                .filter { selectedSeasons.contains($0) }
                .map { $0.displayName }
                .joined(separator: ", ")
        }
    }
}

#Preview {
    MyClosetView()
}
