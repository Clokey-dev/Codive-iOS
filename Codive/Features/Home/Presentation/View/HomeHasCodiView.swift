//
//  HomeHasCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import SwiftUI

struct HomeHasCodiView: View {
    @ObservedObject var viewModel: HomeViewModel
    let width: CGFloat
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            VStack(alignment: .leading, spacing: 16) {
                header
                codiDisplayArea
                
                if viewModel.showClothSelector {
                    clothSelector
                }
                
                CustomBanner(text: TextLiteral.Home.bannerTitle) {
                    viewModel.rememberCodi()
                }
                .padding()
            }
            
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
    
    private var header: some View {
        HStack {
            Text("\(TextLiteral.Home.todayCodiTitle)(\(viewModel.todayString))")
                .font(.title2)
                .padding(.horizontal, 20)
            Spacer()
        }
    }

    private var codiDisplayArea: some View {
        // 가장 바깥쪽 ZStack에 GeometryReader를 사용하여 전체 캔버스 크기를 잡습니다.
        GeometryReader { canvasProxy in
            let canvasSize = canvasProxy.size
            
            ZStack(alignment: .bottomLeading) {
                // 1. 배경 사각형
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.Codive.grayscale7)
                    .frame(width: canvasSize.width, height: canvasSize.height)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    }

                // 2. 코디 아이템들 (이미지 레이어)
                ForEach(viewModel.codiItems) { item in
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: item.width, height: item.height)
                        .position(x: item.x, y: item.y)
                }
                
                if let selectedID = viewModel.selectedItemID,
                   let selectedItem = viewModel.codiItems.first(where: { $0.id == selectedID }) {
                    
                    ForEach(viewModel.selectedItemTags) { tag in
                        CustomTagView(type: .basic(
                            title: tag.title,
                            content: tag.content
                        ))
                        .position(
                            x: selectedItem.x + (tag.locationX - 0.5) * selectedItem.width,
                            y: selectedItem.y + (tag.locationY - 0.5) * selectedItem.height
                        )
                        .offset(x: tag.isRightSide ? 120 : -120)
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(100) // 명시적으로 높은 zIndex 부여
                    }
                }

                Button(action: viewModel.toggleClothSelector) {
                    Image("ic_tag")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                .padding([.leading, .bottom], 16)
            }
        }
        .frame(width: max(width - 40, 0), height: max(width - 40, 0))
        .padding(.horizontal, 20)
    }
    
    private var clothSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.codiItems) { item in
                    SelectableClothItem(
                        entity: item,
                        isSelected: Binding(
                            get: { viewModel.selectedItemID == item.id },
                            set: { newValue in
                                if newValue {
                                    viewModel.selectItem(item.id)
                                } else if viewModel.selectedItemID == item.id {
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
