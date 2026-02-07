//
//  HomeHasCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import SwiftUI

struct HomeHasCodiView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: HomeViewModel
    let width: CGFloat
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                header
                
                GeometryReader { canvasProxy in
                    let canvasSize = canvasProxy.size
                    
                    ZStack(alignment: .bottomLeading) {
                        boardBackground(size: canvasSize)
                        
                        if let selectedID = viewModel.selectedItemID,
                           let selectedItem = viewModel.codiItems.first(where: { $0.coordinateClothId == Int64(selectedID) }) {
                            tagOverlay(for: selectedItem, in: canvasSize)
                        }
                        
                        tagToggleButton
                    }
                }
                .frame(width: max(width - 40, 0), height: max(width - 40, 0))
                .padding(.horizontal, 20)
                
                if viewModel.showClothSelector {
                    clothSelector
                }
                
                bottomBanner
            }
            
            overflowMenu
        }
    }
}

// MARK: - View Components
private extension HomeHasCodiView {
    var header: some View {
        HStack {
            Text("\(TextLiteral.Home.todayCodiTitle)(\(viewModel.todayString))")
                .font(.title2)
                .padding(.horizontal, 20)
            Spacer()
        }
    }
    
    /// 하단 배너
    var bottomBanner: some View {
        CustomBanner(text: TextLiteral.Home.bannerTitle) {}
            .padding()
    }
    
    /// 우측 상단 오버플로우 메뉴
    var overflowMenu: some View {
        CustomOverflowMenu(
            menuType: .coordination,
            menuActions: [
                { viewModel.selectEditCodi() },
                { viewModel.addLookbook() },
                { viewModel.sharedCodi() }
            ]
        )
        .zIndex(9999)
    }
}

// MARK: - Helper Methods & Subviews
private extension HomeHasCodiView {
    func boardBackground(size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.gray.opacity(0.1))
            .overlay {
                if let imageUrl = viewModel.todayCodiPreview?.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
    }
    
    @ViewBuilder
    func tagOverlay(for item: CodiItemEntity, in canvasSize: CGSize) -> some View {
        CustomTagView(type: .basic(
            title: item.brand,
            content: item.name
        ))
        .position(
            x: canvasSize.width * CGFloat(item.locationX),
            y: canvasSize.height * CGFloat(item.locationY)
        )
        .transition(.opacity.combined(with: .scale))
    }
    
    /// 태그 표시 토글 버튼
    var tagToggleButton: some View {
        Button(action: viewModel.toggleClothSelector) {
            Image("ic_tag")
                .resizable()
                .frame(width: 28, height: 28)
        }
        .padding([.leading, .bottom], 16)
    }
    
    var clothSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.codiItems, id: \.coordinateClothId) { item in
                    SelectableClothItem(
                        entity: item,
                        isSelected: .init(
                            get: { viewModel.selectedItemID == Int(item.coordinateClothId) },
                            set: { newValue in
                                if newValue {
                                    viewModel.selectItem(Int(item.coordinateClothId))
                                } else {
                                    viewModel.selectItem(nil)
                                }
                            }
                        )
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
