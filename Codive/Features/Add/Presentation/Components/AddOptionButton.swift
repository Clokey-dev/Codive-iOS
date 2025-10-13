//
//  AddOptionButton.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

struct AddOptionButton: View {
    let iconName: String
    let iconBackgroundColor: Color
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 아이콘 영역
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(iconName)
                       .resizable()
                       .scaledToFit()
                       .frame(width: 28, height: 28)
                }
                
                // 텍스트 영역
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}
