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
                // 이미지 자리 (흰색에 가까운 밝은 회색)
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
    
    // 예시 데이터 (테스트용)
    let items: [ClothItem] = [
        ClothItem(color: Color(red: 0.65, green: 0.55, blue: 0.45)), // 갈색
        ClothItem(color: .red),
        ClothItem(color: .blue),
        ClothItem(color: .green),
        ClothItem(color: .purple),
        ClothItem(color: .orange)
    ]
    
    let spacing: CGFloat = 10
    
    // 현재 중앙에 있는 아이템의 인덱스를 저장합니다.
    // 수정
    @State private var currentIndex: Int

    init() {
        // items 배열의 중앙 인덱스를 기본값으로 설정
        _currentIndex = State(initialValue: items.count / 2)
    }
    
    // 스케일 설정
    let activeScale: CGFloat = 1.0
    let inactiveScale: CGFloat = 0.9
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                
                let screenWidth = geometry.size.width
                // 아이템 너비를 화면 너비의 60%로 설정하여 좌우 미리보기 영역을 확보합니다.
                let itemWidth: CGFloat = screenWidth * 0.4
                // 중앙 정렬을 위한 패딩을 계산합니다.
                let horizontalPadding: CGFloat = (screenWidth - itemWidth) / 2
                
                ScrollViewReader { proxy in
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        LazyHStack(spacing: spacing) {
                            
                            ForEach(items.indices, id: \.self) { index in
                                
                                ClothCardView(item: items[index], width: itemWidth)
                                    .id(index) // ScrollViewReader 참조 ID
                                
                                // MARK: - 인덱스 기반 스케일링 (스냅된 아이템만 확대)
                                    .scaleEffect(index == currentIndex ? activeScale : inactiveScale)
                                    .animation(.spring(), value: currentIndex)
                            }
                        }
                        .padding(.horizontal, horizontalPadding) // 중앙 정렬 패딩
                        
                        // MARK: - iOS 16 수동 스냅 로직
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    
                                    let offset = value.translation.width
                                    let predictedOffset = value.predictedEndTranslation.width
                                    
                                    var newIndex = currentIndex
                                    
                                    // 드래그 거리가 아이템 너비의 1/3을 넘거나, 속도가 빠르면 이동합니다.
                                    if abs(offset) > itemWidth / 3 || abs(predictedOffset) > 100 {
                                        if offset > 0 { // 오른쪽 스와이프 (이전 아이템)
                                            newIndex = max(0, currentIndex - 1)
                                        } else { // 왼쪽 스와이프 (다음 아이템)
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
                // 사각형 안에 스크롤을 넣는 스타일 적용
                // 뷰 영역을 둥근 사각형 모양으로 자릅니다.
                .clipShape(RoundedRectangle(cornerRadius: 20))
                // 스크롤 뷰 배경을 흰색으로 설정하여 상위 뷰의 배경색과 구분합니다.
                .background(Color.Codive.grayscale7)
            }
            // 둥근 사각형 스타일이 적용되도록 뷰의 높이를 설정합니다.
            .frame(height: 148)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text("바지")
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.Codive.main3)
                .clipShape(Capsule())
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
        }
    }
}

#Preview {
    CodiClothView()
        .padding(.horizontal, 20)
}
