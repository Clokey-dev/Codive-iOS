//
//  BlockMenuPopup.swift
//  Codive
//
//  Created by 한태빈 on 1/6/26.
//

import SwiftUI

struct BlockMenuPopup: View {
    let onBlock: () -> Void

    var body: some View {
        Button(action: onBlock) {
            HStack(spacing: 8) {
                Image("ic_block")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(Color.Codive.main1)

                Text("차단하기")
                    .font(.codive_body2_regular)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
            .padding(.vertical, 8)
            .padding(.leading, 16)
            .padding(.trailing, 24)
            .frame(width: 121, height: 40)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .codiveCardShadow()
        }
        .buttonStyle(.plain)
    }
}
