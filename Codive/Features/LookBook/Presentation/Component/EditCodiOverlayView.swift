//
//  EditCodiOverlayView.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

struct EditCodiOverlayView: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    private let timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
            
            VStack(spacing: 14) {
                ZStack {
                    Circle() // 파동 효과
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 50, height: 50)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Circle() // 중심점
                        .fill(Color.white)
                        .frame(width: 16, height: 16)
                }
                
                Text("코디를 수정해보세요")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .onAppear { performAnimation() }
        .onReceive(timer) { _ in performAnimation() }
    }
    
    private func performAnimation() {
        scale = 0; opacity = 1
        withAnimation(.easeOut(duration: 0.8)) {
            scale = 1.5
            opacity = 0
        }
    }
}
