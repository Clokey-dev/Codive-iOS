//
//  CodiClothView.swift
//  Codive
//
//  Created by 한금준 on 10/12/25.
//

import SwiftUI

struct ClothItem: Identifiable {
    let id = UUID()
    let color: Color
}

struct ClothCardView: View {
    let item: ClothItem
    let width: CGFloat
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                // 이미지 자리
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.Codive.main0)
                    .frame(height: 124)
                    .frame(width: 124)
            }
            .frame(width: width)
        }
    }
}

struct CodiClothView: View {
    let title: String
    
    // 예시 데이터
    let items: [ClothItem] = [
        ClothItem(color: Color(red: 0.65, green: 0.55, blue: 0.45)),
        ClothItem(color: .red),
        ClothItem(color: .blue),
        ClothItem(color: .green),
        ClothItem(color: .purple),
        ClothItem(color: .orange)
    ]
    
    let spacing: CGFloat = 10
    
    @State private var currentIndex: Int

    init(title: String) {
            self.title = title
        _currentIndex = State(initialValue: items.count / 2)
    }
    
    // 스케일 설정
    let activeScale: CGFloat = 1.0
    let inactiveScale: CGFloat = 0.9
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                
                let screenWidth = geometry.size.width
                let itemWidth: CGFloat = screenWidth * 0.4
                let horizontalPadding: CGFloat = (screenWidth - itemWidth) / 2
                
                ScrollViewReader { proxy in
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        LazyHStack(spacing: spacing) {
                            
                            ForEach(items.indices, id: \.self) { index in
                                
                                ClothCardView(item: items[index], width: itemWidth)
                                    .id(index)
                                    .scaleEffect(index == currentIndex ? activeScale : inactiveScale)
                                    .animation(.spring(), value: currentIndex)
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    
                                    let offset = value.translation.width
                                    let predictedOffset = value.predictedEndTranslation.width
                                    
                                    var newIndex = currentIndex

                                    let dragThresholdRatio: CGFloat = 1.0 / 3.0
                                    let predictedEndOffsetThreshold: CGFloat = 100
                                    
                                    if abs(offset) > itemWidth * dragThresholdRatio || abs(predictedOffset) > predictedEndOffsetThreshold {
                                        if offset > 0 {
                                            newIndex = max(0, currentIndex - 1)
                                        } else {
                                            newIndex = min(items.count - 1, currentIndex + 1)
                                        }
                                    }
                                    
                                    withAnimation(.spring()) {
                                        proxy.scrollTo(newIndex, anchor: .center)
                                        currentIndex = newIndex
                                    }
                                }
                        )
                    }
                    .onAppear {
                        proxy.scrollTo(currentIndex, anchor: .center)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .background(alignment: .center) {
                    Color.Codive.grayscale7
                }
            }
            .frame(height: 148)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(alignment: .center) {
                    Color.Codive.main3
                }
                .clipShape(Capsule())
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
        }
    }
}

#Preview {
    CodiClothView(title: "바지")
        .padding(.horizontal, 20)
}
