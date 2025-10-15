//
//  AddOptionButton.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

struct AddOptionButton: View {
    let iconName: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 아이콘 영역
                Image(iconName)
                   .resizable()
                   .scaledToFit()
                   .frame(width: 25, height: 25)
                
                // 텍스트 영역
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.codive_body1_medium)
                        .foregroundStyle(Color.Codive.grayscale1)
                    
                    Text(description)
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 15)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .Codive.grayscale1.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}
