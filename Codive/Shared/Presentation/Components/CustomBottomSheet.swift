//
//  CustomBottomSheet.swift
//  Codive
//
//  Created by 한태빈 on 10/6/25.
//

import SwiftUI

struct CustomBottomSheet: View {
    let iconName1: String
    let iconName2: String
    let title1: String
    let title2: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .foregroundStyle(Color("Grayscale5"))
                .frame(minWidth: 69, maxHeight: 4)
                .padding(.bottom, 33)
                .padding(.top, 11)
                .padding(.horizontal, 152)
            
            

            // Row 1
            HStack(spacing: 16) {
                Image(iconName1)
                    .frame(width: 36, height: 36)
                    .foregroundStyle(Color("main0"))

                Text(title1)
                    .font(.codive_title3)
                    .foregroundStyle(Color("Grayscale1"))

                Spacer()

                Image("backSmall")
                    .foregroundStyle(Color("main0"))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Row 2
            HStack(spacing: 16) {
                Image(iconName2)
                    .frame(width: 36, height: 36)
                    .foregroundStyle(Color("main0"))

                Text(title2)
                    .font(.codive_title3)
                    .foregroundStyle(Color("Grayscale1"))

                Spacer()

                Image("backSmall")
                    .foregroundStyle(Color("main0"))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 56)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = 24
    var corners: UIRectCorner = [.topLeft, .topRight]

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    CustomBottomSheet(
        iconName1: "addCodi",
        iconName2: "recallCodi",
        title1: "새로운 코디 추가하기",
        title2: "이전 코디 불러오기"
    )
        .background(Color.gray.opacity(0.2))
}
