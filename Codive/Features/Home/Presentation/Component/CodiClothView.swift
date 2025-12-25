//
//  CodiClothView.swift
//  Codive
//
//  Created by 한금준 on 10/12/25.
//

import SwiftUI

// MARK: - Model

struct ClothItem: Identifiable {
    let id = UUID()
}

// MARK: - Card (단일 슬롯)

struct ClothCardView: View {
    let item: ClothItem
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
            }
            .frame(width: width)
        }
    }
}

// MARK: - Carousel

struct CodiClothCarouselView: View {
    let items: [ClothItem]
    @Binding var currentIndex: Int
    let spacing: CGFloat
    let activeScale: CGFloat
    let inactiveScale: CGFloat
    let isEmptyState: Bool
    
    // 빈 상태에서 사용하는 3개의 카드 구성
    @ViewBuilder
    private func emptyStateCard(at index: Int, width: CGFloat) -> some View {
        let border = RoundedRectangle(cornerRadius: 15)
            .stroke(
                Color.Codive.main4,
                style: StrokeStyle(lineWidth: 1, dash: [6])
            )
        
        switch index {
        case 1:
            // 가운데 카드: 텍스트 + 플러스 아이콘
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
            // 양옆 카드: 투명 배경 + 점선 테두리만
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
                                // 빈 상태에서는 드래그/스크롤 동작 X
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

// MARK: - Entry View

struct CodiClothView: View {
    let title: String
    let items: [ClothItem]
    let isEmptyState: Bool
    
    private let spacing: CGFloat = 10
    private let activeScale: CGFloat = 1.0
    private let inactiveScale: CGFloat = 0.9
    
    @State private var currentIndex: Int
    
    init(title: String,
         items: [ClothItem] = [],
         isEmptyState: Bool) {
        
        self.title = title
        self.items = items
        self.isEmptyState = isEmptyState
        
        let initialIndex = isEmptyState ? 1 : max(0, items.count / 2)
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
            
            Image("move")
                .resizable()
                .scaledToFit()
                .frame(width: 11)
        }
    }
}

// MARK: - Preview

#Preview {
    // 빈 상태 미리보기 (3칸 + 안내 카드)
    CodiClothView(title: "바지", items: [], isEmptyState: true)
        .padding(.horizontal, 20)
}
