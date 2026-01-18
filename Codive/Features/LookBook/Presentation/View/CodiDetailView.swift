//
//  CodiDetailView.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

struct CodiDetailView: View {
    
    // MARK: - State Object
    
    @StateObject private var viewModel: CodiDetailViewModel
    
    // MARK: - Initializer
    
    init(viewModel: CodiDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // MARK: Top Navigation Bar
                
                topBar
                
                // MARK: Scrollable Content
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // MARK: Codi Display Area
                        
                        codiDisplayArea(width: geometry.size.width)
                        
                        // MARK: Cloth Selector Toggle Area
                        
                        if viewModel.showClothSelector {
                            clothSelector
                        }
                        
                        // MARK: Codi Info Section
                        
                        if let detail = viewModel.codiDetail {
                            CodiInfoSection(
                                name: detail.name,
                                memo: detail.memo
                            )
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .onAppear {
            viewModel.fetchCodiDetail()
        }
        .alert(TextLiteral.LookBook.codiDelete, isPresented: $viewModel.showDeleteAlert) {
            Button(TextLiteral.Common.cancel, role: .cancel) { }
            Button(TextLiteral.Common.delete, role: .destructive) {
                viewModel.deleteCodi()
            }
        } message: {
            Text(TextLiteral.LookBook.alertDeleteTitle)
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        CustomNavigationBar(
            title: viewModel.codiDetail?.name ?? TextLiteral.LookBook.codiDetail,
            onBack: viewModel.handleBackTap,
            rightButton: .overflow(
                menuType: .closet,
                menuActions: [
                    { viewModel.navigateToEditCodi() },
                    { viewModel.requestDelete() }
                ]
            )
        )
        .zIndex(10)
        .padding(.leading, 15)
    }
    
    // MARK: - Codi Display Area
    
    private func codiDisplayArea(width: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            
            // MARK: Background Frame
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
                .frame(
                    width: max(width - 40, 0),
                    height: max(width - 40, 0)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                }
                .padding(.horizontal, 20)
            
            // MARK: Codi Image
            
            if let detail = viewModel.codiDetail {
                RemoteFillImage(urlString: detail.imageURL)
                    .frame(width: width - 80, height: width - 80)
                    .position(
                        x: width / 2,
                        y: (width - 40) / 2
                    )
            }
            
            // MARK: Tag Button
            
            Button(action: viewModel.toggleClothSelector) {
                Image("ic_tag")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 36)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Cloth Selector
    
    private var clothSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: Selected Cloth Info
            
            /// 현재 선택된 의류 정보 표시
            if let selectedIndex = viewModel.selectedIndex,
               selectedIndex < viewModel.clothItems.count {
                SelectedClothInfo(
                    entity: viewModel.clothItems[selectedIndex]
                )
                .padding(.horizontal, 20)
            }
            
            // MARK: Cloth Item List
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(
                        Array(viewModel.clothItems.enumerated()),
                        id: \.element.id
                    ) { index, item in
                        SelectableClothItem(
                            entity: CodiItemEntity(
                                id: item.id,
                                imageName: item.imageName,
                                clothName: "",
                                brandName: "",
                                description: "",
                                x: 0,
                                y: 0,
                                width: 68,
                                height: 68
                            ),
                            isSelected: Binding(
                                get: { viewModel.selectedIndex == index },
                                set: { newValue in
                                    if newValue {
                                        viewModel.selectCloth(at: index)
                                    } else if viewModel.selectedIndex == index {
                                        viewModel.selectCloth(at: -1)
                                    }
                                }
                            )
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Supporting Views

/// 코디 이름 / 메모 표시 섹션
private struct CodiInfoSection: View {
    let name: String
    let memo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(TextLiteral.LookBook.codiNameTitle).font(.headline)
                Text(name).font(.body)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(TextLiteral.LookBook.memoTitle).font(.headline)
                Text(memo)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
}

/// 선택된 의류의 브랜드 / 이름 표시 뷰
private struct SelectedClothInfo: View {
    let entity: CodiItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entity.brand)
                .font(.caption)
                .foregroundColor(.gray)
            Text(entity.name)
                .font(.body)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

/// 서버 이미지 비율 유지 표시용 이미지 뷰
private struct RemoteFillImage: View {
    let urlString: String
    
    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
    }
}
