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
}
