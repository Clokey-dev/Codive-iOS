//
//  SplashView.swift
//  Codive
//
//  Created by 황상환 on 12/27/25.
//

import SwiftUI

struct SplashView: View {
    
    // MARK: - Properties
    let fullText: String = "Codive"
    @State private var displayedText: String = ""
    @State private var textIndex: Int = 0
    
    // 애니메이션 설정값
    let typingSpeed: Double = 0.4
    let cursorWidth: CGFloat = 2
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ZStack(alignment: .leading) {
                
                HStack(alignment: .center, spacing: 2) {
                    Text(fullText)
                        .font(.system(size: 60, weight: .bold))
                    
                    Rectangle()
                        .frame(width: cursorWidth, height: 50)
                }
                .opacity(0)
                
                HStack(alignment: .center, spacing: 2) {
                    Text(displayedText)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(Color(red: 50/255, green: 34/255, blue: 34/255))
                    
                    Rectangle()
                        .fill(Color(red: 50/255, green: 34/255, blue: 34/255))
                        .frame(width: cursorWidth, height: 50)
                }
            }
        }
        .onAppear {
            startTyping()
        }
    }

    // MARK: - Private Methods
    private func startTyping() {
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if textIndex < fullText.count {
                textIndex += 1
                let index = fullText.index(fullText.startIndex, offsetBy: textIndex)
                displayedText = String(fullText[..<index])
            } else {
                timer.invalidate()
                // 다음 화면으로 넘어가는 로직을 트리거
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashView()
}
