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
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background Image
            Image(uiImage: photo.croppedImage)
                .resizable()
                .aspectRatio(3/4, contentMode: .fit)
                .cornerRadius(10)
            
            // Dark Overlay
            Color.black.opacity(0.5)
                .cornerRadius(10)
            
            // Animated Circle with Text
            VStack(spacing: 14) {
                ZStack {
                    // Animated Expanding Circle
                    Circle()
                        .fill(Color.Codive.grayscale4)
                        .frame(width: 49, height: 49)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    // Static Base Circle
                    Circle()
                        .fill(Color.Codive.grayscale5)
                        .overlay(
                            Circle()
                                .stroke(Color.Codive.grayscale7, lineWidth: 1)
                        )
                        .frame(width: 16, height: 16)
                }
                
                Text("오늘 입은 옷을 태그해보세요")
                    .font(.codive_body1_medium)
                    .foregroundStyle(Color.white)
            }
        }
        .onTapGesture {
            onTap()
        }
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Methods
    private func startAnimation() {
        // 초기 상태 설정
        scale = 0
        opacity = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.3, repeats: true) { _ in
            // 초기화
            scale = 0
            opacity = 0
            
            // 약간의 딜레이 후 애니메이션 시작
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                // 0.7초 동안 커지기
                withAnimation(.easeOut(duration: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                // 0.7초 후 페이드아웃
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        opacity = 0
                    }
                }
            }
        }
        
        // 즉시 첫 애니메이션 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeOut(duration: 0.4)) {
                    opacity = 0
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleImage = UIImage(systemName: "photo")!
    let photo = SelectedPhoto(id: "1", originalImage: sampleImage, order: 1)
    
    return AnimatedPhotoCard(photo: photo) {
        print("Photo tapped")
    }
    .frame(width: 300, height: 400)
}
