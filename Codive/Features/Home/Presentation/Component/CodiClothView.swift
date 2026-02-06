//
//  CodiClothView.swift
//  Codive
//
//  Created by 한금준 on 10/12/25.
//

import SwiftUI

struct ClothCardView: View {
    let item: HomeClothEntity
    let width: CGFloat
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                Color.Codive.main4,
                                style: StrokeStyle(lineWidth: 1, dash: [6])
                            )
                    )
                    .frame(height: 124)
                    .frame(width: 124)
                    .overlay {
                        if let url = URL(string: item.imageUrl), !item.imageUrl.isEmpty {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable().scaledToFit()
                                case .failure:
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        } else {
                            Image(item.imageUrl)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
            }
            .frame(width: width)
        }
    }
}

struct CodiClothCarouselView: View {
    let items: [HomeClothEntity]
    @Binding var currentIndex: Int
    let spacing: CGFloat
    let activeScale: CGFloat
    let inactiveScale: CGFloat
    let isEmptyState: Bool
    
    @ViewBuilder
    private func emptyStateCard(at index: Int, width: CGFloat) -> some View {
        let border = RoundedRectangle(cornerRadius: 15)
            .stroke(
                Color.Codive.main4,
                style: StrokeStyle(lineWidth: 1, dash: [6])
            )
        
        switch index {
        case 1:
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .overlay(border)
                    .frame(height: 124)
                    .frame(width: 124)
                
                VStack(spacing: 10) {
                    Text(TextLiteral.Home.noClothTitle)
                        .font(.codive_body2_medium)
                        .foregroundColor(Color.Codive.grayscale1)
                    
                    Text(TextLiteral.Home.noClothDescription)
                        .font(.codive_body3_regular)
                        .foregroundColor(Color.Codive.grayscale3)
                        .padding(.top, 4)
                    
                    Image("plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }
            }
            .frame(width: width)
            
        default:
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.clear)
                    .overlay(border)
                    .frame(height: 124)
                    .frame(width: 124)
            }
            .frame(width: width)
        }
    }
    
    @ViewBuilder
    private func card(at index: Int, width: CGFloat) -> some View {
        if isEmptyState {
            emptyStateCard(at: index, width: width)
        } else {
            ClothCardView(item: items[index], width: width)
        }
    }
    
    // MARK: Body
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let itemWidth: CGFloat = screenWidth * 0.4
            let horizontalPadding: CGFloat = (screenWidth - itemWidth) / 2
            let totalCount = isEmptyState ? 3 : items.count
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: spacing) {
                        ForEach(0..<totalCount, id: \.self) { index in
                            card(at: index, width: itemWidth)
                                .id(index)
                                .scaleEffect(index == currentIndex ? activeScale : inactiveScale)
                                .animation(.spring(), value: currentIndex)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if isEmptyState { return }
                                
                                let offset = value.translation.width
                                let predictedOffset = value.predictedEndTranslation.width
                                
                                var newIndex = currentIndex
                                
                                let dragThresholdRatio: CGFloat = 1.0 / 3.0
                                let predictedEndOffsetThreshold: CGFloat = 100
                                
                                if abs(offset) > itemWidth * dragThresholdRatio ||
                                    abs(predictedOffset) > predictedEndOffsetThreshold {
                                    
                                    if offset > 0 {
                                        newIndex = max(0, currentIndex - 1)
                                    } else {
                                        newIndex = min(totalCount - 1, currentIndex + 1)
                                    }
                                }
                                
                                withAnimation(.spring()) {
                                    proxy.scrollTo(newIndex, anchor: .center)
                                    currentIndex = newIndex
                                }
                            }
                    )
                }
                .onChange(of: currentIndex) { newValue in
                    withAnimation(.spring()) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
                .scrollDisabled(isEmptyState)
                .onAppear {
                    proxy.scrollTo(currentIndex, anchor: .center)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .background {
                Color.Codive.grayscale7
            }
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CodiClothView: View {
    let title: String
    let items: [HomeClothEntity]
    let isEmptyState: Bool

    let spacing: CGFloat = 12
    let activeScale: CGFloat = 1.0
    let inactiveScale: CGFloat = 0.85
    let selectedIndex: Int
    var onIndexChanged: ((Int) -> Void)?
    
    @State private var currentIndex: Int
    
    init(title: String, items: [HomeClothEntity], selectedIndex: Int = 0, isEmptyState: Bool, onIndexChanged: ((Int) -> Void)? = nil) {
        self.title = title
        self.items = items
        self.isEmptyState = isEmptyState
        self.selectedIndex = selectedIndex
        self.onIndexChanged = onIndexChanged
        
        // 초기값 설정: 비어있으면 1(중앙), 아니면 전달받은 selectedIndex 사용
        let initialIndex = isEmptyState ? 1 : selectedIndex
        _currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .topLeading) {
                CodiClothCarouselView(
                    items: items,
                    currentIndex: $currentIndex,
                    spacing: spacing,
                    activeScale: activeScale,
                    inactiveScale: inactiveScale,
                    isEmptyState: isEmptyState
                )
                .onChange(of: currentIndex) { newValue in
                    onIndexChanged?(newValue)
                }
                // 중요: 부모가 준 selectedIndex가 바뀌면(수정 버튼 클릭 시) 내부 currentIndex도 동기화
                .onChange(of: selectedIndex) { newValue in
                    withAnimation(.spring()) {
                        self.currentIndex = newValue
                    }
                }
                .onAppear {
                    // 비어있는 상태가 아닐 때만 0번(또는 초기값)을 전달
                    if !isEmptyState {
                        onIndexChanged?(currentIndex)
                    }
                }
                
                // 카테고리 태그
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background {
                        Color.Codive.main3
                    }
                    .clipShape(Capsule())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
            
            // 이동 핸들 아이콘
            Image("move")
                .resizable()
                .scaledToFit()
                .frame(width: 11)
                .padding(.trailing, 12)
                .contentShape(Rectangle()) // 터치 영역 확장
        }
        .background(Color.white)
    }
}
