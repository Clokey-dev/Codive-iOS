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
                .frame(width: 204, height: 204)
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
    let containerSize: CGFloat = 204
    let itemSize: CGFloat = 102 // 50% 사이즈 (204 / 2) - 필요에 따라 조절

    var body: some View {
        ZStack {
            // 투명 정사각형 배경
            Rectangle()
                .fill(Color.clear)
                .frame(width: containerSize, height: containerSize)

            // Case 별 레이아웃 처리
            ForEach(0..<clothes.count, id: \.self) { index in
                let position = calculatePosition(for: index, totalCount: clothes.count)
                
                AsyncImage(url: URL(string: clothes[index].imageUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: itemSize * 0.8, height: itemSize * 0.8) // 50% 수준으로 시각적 조정
                .position(x: position.x, y: position.y)
            }
        }
    }

    private func calculatePosition(for index: Int, totalCount: Int) -> CGPoint {
        let center = containerSize / 2
        let quarter = containerSize / 4
        let eighth = containerSize / 8
        let spacing = containerSize / 3 // 3열 배치용 간격

        switch totalCount {
        case 1: // Case 1: 정중앙
            return CGPoint(x: center, y: center)
            
        case 2: // Case 2: HStack 중앙
            return index == 0 ? CGPoint(x: quarter, y: center) : CGPoint(x: quarter * 3, y: center)
            
        case 3: // Case 3: VStack 1열 중앙
            let yPos = [quarter, center, quarter * 3]
            return CGPoint(x: center, y: yPos[index])
            
        case 4...7: // Case 4-7: 왼쪽/오른쪽 열 배치
            let leftCount = totalCount == 7 ? 4 : 3
            let isLeftColumn = index < leftCount
            let xPos = isLeftColumn ? quarter : quarter * 3
            
            // 각 열 내부에서의 인덱스
            let internalIndex = isLeftColumn ? index : index - leftCount
            
            // y축 계산 (왼쪽 상단 기준 정렬)
            let rowSpacing = containerSize / CGFloat(max(leftCount, 1) + 1)
            let yPos = rowSpacing * CGFloat(internalIndex + 1)
            
            return CGPoint(x: xPos, y: yPos)

        default:
            return CGPoint(x: center, y: center)
        }
    }
}

//#Preview {
//    CompletePopUp(
//        isPresented: .constant(true),
//        onRecordTapped: {},
//        onCloseTapped: {},
//        imageURL: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800"
//    )
//}
