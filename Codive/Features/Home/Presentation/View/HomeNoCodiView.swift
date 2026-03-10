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
    
    var codiClothList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(viewModel.activeCategories, id: \.id) { category in
                    let items: [HomeClothEntity] = viewModel.clothItemsByCategory[category.id] ?? []
                    let selectedIdx = Binding(
                        get: { viewModel.selectedIndicesByCategory[category.id] ?? 0 },
                        set: { viewModel.selectedIndicesByCategory[category.id] = $0 }
                    )
                    
                    CodiClothView(
                        title: category.title,
                        items: items,
                        isEmptyState: items.isEmpty,
                        currentIndex: selectedIdx
                    ) {
                        viewModel.navigateToAddCloth()
                    }
                    .id(category.id)
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
