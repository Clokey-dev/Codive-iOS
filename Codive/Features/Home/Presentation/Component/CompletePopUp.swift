//
//  CompletePopUp.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

import SwiftUI

struct CompletePopUp: View {
    @Binding var isPresented: Bool
    var onRecordTapped: () -> Void
    var onCloseTapped: () -> Void
    
    // 수정: 단일 URL 대신 선택된 옷 리스트를 받음
    var selectedClothes: [HomeClothEntity]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack {
                popupCard
                    .padding(.horizontal, 32)
            }
        }
    }
    
    private var popupCard: some View {
        VStack(spacing: 6) {
            Text(TextLiteral.Home.popUpTitle).font(.codive_title1).padding(.top, 32)
            Text(TextLiteral.Home.popUpSubtitle).font(.codive_body2_regular).padding(.horizontal, 24)
            
            // 핵심 수정 부분: 이미지 합성 뷰
            CodiCompositeView(clothes: selectedClothes)
                .frame(width: 260, height: 260)
                .padding(.vertical, 16)
            
            HStack(spacing: 9) {
                CustomButton(text: TextLiteral.Home.close, widthType: .half, styleType: .border) {
                    isPresented = false
                    onCloseTapped()
                }
                CustomButton(text: TextLiteral.Home.record, widthType: .half) {
                    onRecordTapped()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
    }
}

// MARK: - 합성 레이아웃 뷰
struct CodiCompositeView: View {
    let clothes: [HomeClothEntity]
    // 204 -> 260으로 변경 (아이템 3~4개 수직 배치 시 약 250pt 필요)
    let containerSize: CGFloat = 260
    let itemSize: CGFloat = 100
    
    var body: some View {
        ZStack {
            // 배경 영역 (검정색 사각형이 이제 260 사이즈를 가집니다)
            Rectangle()
                .fill(Color.clear)
                .frame(width: containerSize, height: containerSize)
                .cornerRadius(12) // 모서리를 살짝 깎으면 더 부드럽습니다
            
            // 아이템 배치
            ForEach(0..<clothes.count, id: \.self) { index in
                let position = CodiLayoutCalculator.position(
                    index: index,
                    totalCount: clothes.count,
                    containerSize: containerSize
                )
                
                AsyncImage(url: URL(string: clothes[index].imageUrl)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: itemSize, height: itemSize)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .position(x: position.x, y: position.y)
                .zIndex(Double(index))
            }
        }
        // 중요: ZStack 자체에 프레임을 주어 밖으로 나가는 것을 방지합니다.
        .frame(width: containerSize, height: containerSize)
        .clipped()
    }
    
//    private func calculatePosition(for index: Int, totalCount: Int) -> CGPoint {
//        let center = containerSize / 2
//        
//        let stepFor3 = itemSize - 25 // 세로 25 겹침 (간격 75)
//        let stepFor4 = itemSize - 36 // 세로 36 겹침 (간격 64)
//        let horizontalOverlap: CGFloat = 12
//        let horizontalStep = itemSize - horizontalOverlap // 수평 12 겹침 (간격 88)
//        
//        switch totalCount {
//        case 1:
//            return CGPoint(x: center, y: center)
//            
//        case 2:
//            let totalW = itemSize + stepFor3
//            let startX = (containerSize - totalW) / 2 + (itemSize / 2)
//            return CGPoint(x: startX + (CGFloat(index) * stepFor3), y: center)
//            
//        case 3:
//            let totalH = itemSize + (stepFor3 * 2)
//            let startY = (containerSize - totalH) / 2 + (itemSize / 2)
//            return CGPoint(x: center, y: startY + (CGFloat(index) * stepFor3))
//            
//        case 4...7:
//            // 열 구분 (7개일 때만 왼쪽이 4개, 그 외에는 왼쪽 3개 배치)
//            let leftCount = (totalCount == 7) ? 4 : 3
//            let rightCount = totalCount - leftCount
//            
//            // 1. 세로 시작점(startY) 계산: 왼쪽 열 기준 중앙 정렬
//            let leftStep = (leftCount == 4) ? stepFor4 : stepFor3
//            let leftTotalH = itemSize + (leftStep * CGFloat(leftCount - 1))
//            let startY = (containerSize - leftTotalH) / 2 + (itemSize / 2)
//            
//            // 2. 가로 위치(xPos) 계산: 두 열 사이 12pt 겹침 적용
//            // 두 열의 총 너비 = itemSize + horizontalStep (88) = 188
//            let totalW = itemSize + horizontalStep
//            let startX = (containerSize - totalW) / 2 + (itemSize / 2)
//            
//            let isLeftColumn = index < leftCount
//            let internalIndex = isLeftColumn ? index : index - leftCount
//            
//            // 왼쪽 열은 startX, 오른쪽 열은 startX + 88
//            let xPos = isLeftColumn ? startX : startX + horizontalStep
//            
//            // 3. 세로 위치(yPos) 계산
//            let currentColumnTotal = isLeftColumn ? leftCount : rightCount
//            let step = (currentColumnTotal == 4) ? stepFor4 : stepFor3
//            
//            return CGPoint(x: xPos, y: startY + (CGFloat(internalIndex) * step))
//            
//        default:
//            return CGPoint(x: center, y: center)
//        }
//    }
}
