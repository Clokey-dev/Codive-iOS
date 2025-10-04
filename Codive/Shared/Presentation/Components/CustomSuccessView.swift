//
//  CustomSuccessView.swift
//  Codive
//
//  Created by 한금준 on 10/4/25.
//

import SwiftUI

struct CustomSuccessView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.Codive.main1)
                .font(.system(size: 50, weight: .bold))
            Text(message)
                .font(Font.codive_title1)
                .foregroundColor(Color.Codive.grayscale1)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Codive.grayscale7)
    }
}

#Preview {
    CustomSuccessView(message: "옷장에 옷을 보관했어요!")
}
