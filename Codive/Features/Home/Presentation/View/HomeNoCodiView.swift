//
//  HomeNoCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import SwiftUI

struct HomeNoCodiView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: HomeViewModel
    @State private var draggingItem: CategoryEntity?

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            categoryButtons
            
            codiClothList
            
            if !viewModel.isAllCategoriesEmpty {
                bottomButtons
            }
        }
        .onAppear {
            viewModel.onAppear()
//            Task {
//                await viewModel.loadRecommendCategoryClothList()
//            }
            Task {
                            // 이미 카테고리 아이템이 있다면(수정 모드 진입 등) 새로 로드하지 않음
                            if viewModel.clothItemsByCategory.isEmpty {
                                await viewModel.loadRecommendCategoryClothList()
                            }
                        }
        }
    }
}

// MARK: - View Components
private extension HomeNoCodiView {
    
    var header: some View {
        Text(TextLiteral.Home.noCodiTitle)
            .font(.codive_title1)
            .foregroundStyle(Color.Codive.grayscale1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)
    }
    
    var categoryButtons: some View {
        HStack(spacing: 8) {
            CodiButton(iconName: "plus", title: TextLiteral.Home.edit) {
                viewModel.handleEditCategory()
            }
            CodiButton(iconName: "shuffle", title: TextLiteral.Home.random) {
                // 랜덤 로직
                viewModel.selectEditCodi()
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 16)
    }
    
//    var codiClothList: some View {
//        ScrollView(.vertical, showsIndicators: false) {
//            VStack(spacing: 16) {
//                ForEach(viewModel.activeCategories) { category in
//                    let clothItems = viewModel.clothItemsByCategory[category.id] ?? []
//                    
//                    CodiClothView(
//                        title: category.title,
//                        items: clothItems,
//                        isEmptyState: clothItems.isEmpty
//                    ) { newIndex in
//                        viewModel.updateSelectedIndex(for: category.id, index: newIndex)
//                    }
//                    .id("\(category.id)_\(clothItems.count)")
//                    .background(Color.white)
//                    .cornerRadius(15)
    var codiClothList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(viewModel.activeCategories, id: \.id) { category in
                    // 1. 필요한 데이터를 안전하게 추출 (타입 명시)
                    let items: [HomeClothEntity] = viewModel.clothItemsByCategory[category.id] ?? []
                    let selectedIdx: Int = viewModel.selectedIndicesByCategory[category.id] ?? 0
                    
                    // 2. 뷰를 생성할 때 고유 ID는 category.id만 사용 (스크롤 안정성 핵심)
                    CodiClothView(
                        title: category.title,
                        items: items,
                        selectedIndex: selectedIdx,
                        isEmptyState: items.isEmpty,
                        onIndexChanged: { newIndex in
                            viewModel.updateSelectedIndex(for: category.id, index: newIndex)
                        }
                    )
                    .id(category.id) // 여기에 selectedIdx를 포함하면 스크롤 시 뷰가 튀게 됩니다.
                    .background(Color.white)
                    .cornerRadius(15)
                    .onDrag {
                        self.draggingItem = category
                        return NSItemProvider(object: String(category.id) as NSString)
                    }
                    .onDrop(of: [.text], delegate: CategoryDropDelegate(
                        item: category,
                        items: $viewModel.activeCategories,
                        draggingItem: $draggingItem
                    ))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
        }
    }
    
    var bottomButtons: some View {
        HStack(spacing: 16) {
            let totalWidth = UIScreen.main.bounds.width - 56
            codiBoardButton(width: totalWidth / 3)
            confirmButton(width: totalWidth * 2 / 3)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 48)
    }
    
    func codiBoardButton(width: CGFloat) -> some View {
        Button(action: viewModel.handleCodiBoardTap) {
            Text(TextLiteral.Home.codiBoardTitle)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.main0)
                .frame(width: width, height: 48)
                .background(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.Codive.main0, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    func confirmButton(width: CGFloat) -> some View {
        Button(action: viewModel.handleConfirmCodiTap) {
            Text(TextLiteral.Home.decesion)
                .font(.codive_title2)
                .foregroundStyle(.white)
                .frame(width: width, height: 48)
                .background(Color.Codive.main0)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct CategoryDropDelegate: DropDelegate {
    let item: CategoryEntity
    @Binding var items: [CategoryEntity]
    @Binding var draggingItem: CategoryEntity?
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem,
              draggingItem.id != item.id,
              let from = items.firstIndex(where: { $0.id == draggingItem.id }),
              let to = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        if items[to].id != draggingItem.id {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        withAnimation(.easeInOut) {
            draggingItem = nil
        }
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
