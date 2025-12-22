//
//  SpeechBubbleShape.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

struct SpeechBubbleShape: Shape {
    var radius: CGFloat = 10
    var tailSize: CGFloat = 6
    var tailWidth: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bubbleHeight = rect.height - tailSize

        path.move(to: CGPoint(x: radius, y: 0))

        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addArc(
            center: CGPoint(x: rect.width - radius, y: radius),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.width, y: bubbleHeight - radius))
        path.addArc(
            center: CGPoint(x: rect.width - radius, y: bubbleHeight - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.midX + (tailWidth / 2), y: bubbleHeight))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        path.addLine(to: CGPoint(x: rect.midX - (tailWidth / 2), y: bubbleHeight))

        path.addLine(to: CGPoint(x: radius, y: bubbleHeight))
        path.addArc(
            center: CGPoint(x: radius, y: bubbleHeight - radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(
            center: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        return path
    }
}
