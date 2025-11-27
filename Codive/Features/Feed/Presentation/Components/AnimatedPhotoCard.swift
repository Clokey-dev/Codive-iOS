//
//  AnimatedPhotoCard.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import SwiftUI

// MARK: - AnimatedPhotoCard
struct AnimatedPhotoCard: View {
    
    // MARK: - Properties
    let photo: SelectedPhoto
    let onTap: () -> Void
    
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    
    private let timer = Timer.publish(every: 1.3, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Image(uiImage: photo.croppedImage)
                .resizable()
                .aspectRatio(3/4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Color.black.opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.Codive.grayscale4)
                        .frame(width: 49, height: 49)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Circle()
                        .fill(Color.Codive.grayscale5)
                        .overlay(
                            Circle()
                                .stroke(Color.Codive.grayscale7, lineWidth: 1)
                        )
                        .frame(width: 16, height: 16)
                }
                
                Text(TextLiteral.Add.photoTagAnimationText)
                    .font(.codive_body1_medium)
                    .foregroundStyle(Color.white)
            }
        }
        .onTapGesture {
            onTap()
        }
        .onAppear {
            performAnimation()
        }
        .onReceive(timer) { _ in
            performAnimation()
        }
    }

    // MARK: - Methods
    private func performAnimation() {
        // 즉시 초기화 (애니메이션 없이)
        withAnimation(.linear(duration: 0)) {
            scale = 0
            opacity = 0
        }
        
        // 짧은 딜레이 후 커지는 애니메이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.7)) {
                self.scale = 1.0
                self.opacity = 1.0
            }
            
            // 0.7초 후 페이드아웃
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeOut(duration: 0.4)) {
                    self.opacity = 0
                }
            }
        }
    }
}
