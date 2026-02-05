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
                
                //                codiDisplayArea
                //
                //                if viewModel.showClothSelector {
                //                    clothSelector
                //                }
                //
                //                bottomBanner
                //            }
                // 메인 캔버스 영역
                GeometryReader { canvasProxy in
                    let canvasSize = canvasProxy.size
                    
                    ZStack(alignment: .bottomLeading) {
                        // 1. 배경 레이어 (Preview 이미지)
                        boardBackground(size: canvasSize)
                        
                        // 2. 선택된 아이템의 태그 레이어 (Details 좌표 및 정보)
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
    
    /// 상단 헤더 (오늘의 코디 제목 및 날짜)
    var header: some View {
        HStack {
            Text("\(TextLiteral.Home.todayCodiTitle)(\(viewModel.todayString))")
                .font(.title2)
                .padding(.horizontal, 20)
            Spacer()
        }
    }

    /// 코디 아이템 및 태그가 표시되는 메인 캔버스 영역
//    var codiDisplayArea: some View {
//        GeometryReader { canvasProxy in
//            let canvasSize = canvasProxy.size
//            
//            ZStack(alignment: .bottomLeading) {
//                // 배경 레이어
//                boardBackground(size: canvasSize)
//
//                // 이미지 아이템 레이어
//                ForEach(viewModel.codiItems) { item in
//                    Image(item.imageName)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: item.width, height: item.height)
//                        .position(x: item.x, y: item.y)
//                }
//                
//                // 선택된 아이템의 태그 레이어
//                if let selectedID = viewModel.selectedItemID,
//                   let selectedItem = viewModel.codiItems.first(where: { $0.id == selectedID }) {
//                    tagOverlay(for: selectedItem, in: canvasSize)
//                }
//
//                // 태그 셀렉터 토글 버튼
//                tagToggleButton
//            }
//        }
//        .frame(width: max(width - 40, 0), height: max(width - 40, 0))
//        .padding(.horizontal, 20)
//    }
    
    /// 하단 의류 선택 스크롤 뷰
//    var clothSelector: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 12) {
//                ForEach(viewModel.codiItems) { item in
//                    SelectableClothItem(
//                        entity: item,
//                        isSelected: Binding(
//                            get: { viewModel.selectedItemID ?? 0 == item.id },
//                            set: { isSelected in
//                                viewModel.selectItem(isSelected ? Int(item.id) : nil)
//                            }
//                        )
//                    )
//                }
//            }
//            .padding(.horizontal, 20)
//        }
//    }
    
    /// 하단 배너
    var bottomBanner: some View {
        CustomBanner(text: TextLiteral.Home.bannerTitle) {
//            viewModel.rememberCodi()
        }
        .padding()
    }
    
    /// 우측 상단 오버플로우 메뉴
    var overflowMenu: some View {
        CustomOverflowMenu(
            menuType: .coordination,
            menuActions: [
                { viewModel.selectEditCodi() },
                { viewModel.addLookbook() },
                { /*viewModel.sharedCodi()*/ }
            ]
        )
        .zIndex(9999)
    }
}

// MARK: - Helper Methods & Subviews
private extension HomeHasCodiView {
    
    /// 캔버스 배경 디자인
//    func boardBackground(size: CGSize) -> some View {
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color.Codive.grayscale7)
//                .frame(width: size.width, height: size.height)
//                .overlay {
//                    // 서버로부터 받은 이미지 URL이 있다면 표시
//                    if let imageUrl = viewModel.todayCodiPreview?.imageUrl,
//                       let url = URL(string: imageUrl) {
//                        AsyncImage(url: url) { image in
//                            image
//                                .resizable()
//                                .scaledToFill() // 배경을 꽉 채우도록 설정
//                                .frame(width: size.width, height: size.height)
//                                .clipShape(RoundedRectangle(cornerRadius: 15))
//                        } placeholder: {
//                            ProgressView() // 로딩 중 표시
//                        }
//                    }
//                    
//                    // 테두리 유지
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
//                }
//        }
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
    
    /// 태그 표시 로직 분리
//    @ViewBuilder
//    func tagOverlay(for item: CodiItemEntity, in canvasSize: CGSize) -> some View {
//        let isLeftSide = item.x < (canvasSize.width / 2)
//        let tagOffset: CGFloat = 120
//        let tagWidth: CGFloat = 100
//        let tagHeight: CGFloat = 40
//        
//        ForEach(viewModel.selectedItemTags) { tag in
//            let baseX = item.x + (tag.locationX - 0.5) * item.width
//            let baseY = item.y + (tag.locationY - 0.5) * item.height
//            
//            let tagX = baseX + (isLeftSide ? tagOffset : -tagOffset)
//            
//            // 캔버스 이탈 방지 clamping
//            let clampedX = min(max(tagX, tagWidth / 2), canvasSize.width - tagWidth / 2)
//            let clampedY = min(max(baseY, tagHeight / 2), canvasSize.height - tagHeight / 2)
//            
//            CustomTagView(type: .basic(title: tag.title, content: tag.content))
//                .position(x: clampedX, y: clampedY)
//                .transition(.opacity.combined(with: .scale))
//                .zIndex(100)
//        }
//    }
    @ViewBuilder
        func tagOverlay(for item: CodiItemEntity, in canvasSize: CGSize) -> some View {
            CustomTagView(type: .basic(
                title: item.brand,   // 브랜드명 적용
                content: item.name   // 상품명 적용
            ))
            .position(
                x: canvasSize.width * CGFloat(item.locationX), // 비율 좌표를 절대 좌표로 변환
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
    
    // 하단 리스트 (CodiItemEntity 리스트 사용)
        var clothSelector: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.codiItems, id: \.coordinateClothId) { item in
                        SelectableClothItem(
                            entity: item,
                            isSelected: .init(
                                get: { viewModel.selectedItemID == Int(item.coordinateClothId) },
                                set: { _ in viewModel.selectItem(Int(item.coordinateClothId)) }
                            )
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
}
