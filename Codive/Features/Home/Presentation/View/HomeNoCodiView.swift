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
    
    // 현재 드래그 중인 아이템을 추적
    @State private var draggingItem: CategoryEntity?

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            categoryButtons
            
            codiClothList
            
            Spacer()
            
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
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 16)
    }
    
    var codiClothList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.activeCategories) { category in
                    let clothItems = viewModel.clothItemsByCategory[category.id] ?? []
                    
                    CodiClothView(
                        title: category.title,
                        items: clothItems,
                        isEmptyState: clothItems.isEmpty
                    ) { newIndex in
                        viewModel.updateSelectedIndex(for: category.id, index: newIndex)
                    }
                    .background(Color.white)
                    .cornerRadius(15)
                    // 드래그 중인 아이템은 반투명하게 표시
//                    .opacity(draggingItem?.id == category.id ? 0.5 : 1.0)
                    // 드래그 시작 설정
                    .onDrag {
                        self.draggingItem = category
                        return NSItemProvider(object: String(category.id) as NSString)
                    }
                    // 드롭 위치 계산 및 애니메이션 실행
                    .onDrop(of: [.text], delegate: CategoryDropDelegate(
                        item: category,
                        items: $viewModel.activeCategories,
                        draggingItem: $draggingItem
                    ))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
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

// MARK: - Drop Delegate
struct CategoryDropDelegate: DropDelegate {
    let item: CategoryEntity
    @Binding var items: [CategoryEntity]
    @Binding var draggingItem: CategoryEntity?
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem,
              draggingItem.id != item.id,
              let from = items.firstIndex(where: { $0.id == draggingItem.id }),
              let to = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        // 드래그 시 항목이 바뀌는 애니메이션 적용
        if items[to].id != draggingItem.id {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
