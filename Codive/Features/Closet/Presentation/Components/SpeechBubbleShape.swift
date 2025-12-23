//
//  SpeechBubbleShape.swift
//  Codive
//
//  Created by 황상환 on 12/14/25.
//

import SwiftUI

struct SpeechBubbleShape: Shape {
    
    // MARK: - Properties
    let radius: CGFloat = 8
    let tailSize: CGFloat = 4
    let tailWidth: CGFloat = 12

    // MARK: - Path
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bubbleHeight = rect.height - tailSize
        
        path.move(to: CGPoint(x: radius, y: 0))
        
        // 상단 및 우측 모서리
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - radius, y: radius),
                    radius: radius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        // 우측 및 하단 우측 모서리
        path.addLine(to: CGPoint(x: rect.width, y: bubbleHeight - radius))
        path.addArc(center: CGPoint(x: rect.width - radius, y: bubbleHeight - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        
        // 하단 및 꼬리
        path.addLine(to: CGPoint(x: rect.midX + (tailWidth / 2), y: bubbleHeight))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        path.addLine(to: CGPoint(x: rect.midX - (tailWidth / 2), y: bubbleHeight))
        
        // 좌측 하단 모서리
        path.addLine(to: CGPoint(x: radius, y: bubbleHeight))
        path.addArc(center: CGPoint(x: radius, y: bubbleHeight - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        
        // 좌측 및 좌측 상단 모서리
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(center: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        return path
    }
}
