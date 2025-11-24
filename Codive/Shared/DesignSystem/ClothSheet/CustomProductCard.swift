//
//  CustomProductCard.swift
//  Codive
//
//  Created by 황상환 on 11/18/25.
//

import SwiftUI

struct CustomProductCard: View {
    
    // MARK: - Properties
    let imageName: String
    let isTodayCloth: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    // 배경
                    Color.Codive.grayscale6
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // 상품 이미지
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // 선택 시 오버레이
                    if isSelected {
                        Color.black.opacity(0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // 체크 아이콘
                        Image("check_bt")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // 좌상단 라벨 (조건부)
                    if isTodayCloth {
                        Text("오늘의 코디")
                            .font(.codive_body3_medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 3)
                            .background(Color.Codive.point2)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .padding(6)
                    }
                }
            }
            .aspectRatio(3/4, contentMode: .fit)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
