//
//  CustomBanner.swift
//  Codive
//
//  Created by 한금준 on 10/5/25.
//

import SwiftUI

struct CustomBanner: View {
    let text: String
    let onIconTap: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .font(Font.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)
            
            Spacer()
            
            Button(action: onIconTap) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white)
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 24, height: 24)
                    .background(Color.Codive.main1)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color.Codive.main6)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CustomBanner(text: "오늘 이 코디를 기억하고 싶다면?") {
        print("Icon tapped!")
    }
    .padding()
    
    CustomBanner(text: "패션트렌드 편지가 도착했어요") {
        print("Icon tapped!")
    }
    .padding()
}
