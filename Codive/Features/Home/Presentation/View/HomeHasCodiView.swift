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
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.Codive.grayscale7)
                .frame(
                    width: max(width - 40, 0),
                    height: max(width - 40, 0)
                )
                .overlay(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                }
                .padding(.horizontal, 20)
            
            ForEach(viewModel.codiItems) { item in
                ZStack {
                    // 1. 실제 이미지 표시
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: item.width, height: item.height)
                        .overlay(
                            // 2. GeometryReader를 사용하여 이미지 내부 좌표계 확보
                            GeometryReader { proxy in
                                let imageSize = proxy.size
                                
                                // 3. 선택된 아이템인 경우에만 태그 표시
                                if viewModel.selectedItemID == item.id {
                                    ForEach(viewModel.selectedItemTags) { tag in
                                        CustomTagView(type: .basic(
                                            title: tag.brand,
                                            content: tag.content
                                        ))
                                        // 4. 절대 좌표 계산: 상대좌표 * 실제크기
                                        .position(
                                            x: tag.locationX * imageSize.width,
                                            y: tag.locationY * imageSize.height
                                        )
                                        // 5. 드래그를 통한 위치 업데이트 (선택 사항)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    viewModel.updateTagPosition(
                                                        tagId: tag.id,
                                                        x: value.location.x,
                                                        y: value.location.y,
                                                        imageSize: imageSize
                                                    )
                                                }
                                        )
                                    }
                                }
                            }
                        )
                }
                // 전체 캔버스에서의 위치
                .position(x: item.x, y: item.y)
            }
            
            Button(action: viewModel.toggleClothSelector) {
                Image("ic_tag")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 36)
            .padding(.bottom, 16)
        }
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
