//
//  PillToggle.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct PillToggle: View {
    @Binding var isOn: Bool
    var onColor: Color = Color("point1")
    var offColor: Color = .white
    var width: CGFloat = 35
    var height: CGFloat = 18

    var body: some View {
        let knobSize = height - 6

        Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                // 배경 (켜짐: 채움 / 꺼짐: 흰색 + 테두리)
                Capsule()
                    .fill(isOn ? onColor : offColor)
                    .overlay(
                        Capsule().stroke(onColor, lineWidth: 2)
                            .opacity(isOn ? 0 : 1)  // 꺼짐일 때만 테두리 보이게
                    )

                // 손잡이
                Circle()
                    .fill(isOn ? Color.white : onColor)
                    .frame(width: knobSize, height: knobSize)
                    .padding(3)
            }
            .frame(width: width, height: height)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("toggle")
        .accessibilityValue(isOn ? "on" : "off")
    }
}
