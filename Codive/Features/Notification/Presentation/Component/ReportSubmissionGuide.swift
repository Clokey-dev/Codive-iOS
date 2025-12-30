//
//  ReportSubmissionGuide.swift
//  Codive
//
//  Created by 한금준 on 12/30/25.
//

import SwiftUI

// MARK: - 신고 접수 안내 컴포넌트

struct ReportSubmissionGuide: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Image("warning")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.Codive.point1)
                
                // 텍스트 영역
                VStack(alignment: .leading, spacing: 12) {
                    // 제목
                    Text("신고 접수 안내")
                        .font(.codive_body1_medium)
                        .foregroundColor(Color.Codive.grayscale1)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("회원님의 게시글이 운영 정책 위반으로 신고되었습니다.")
                    .font(.codive_body2_regular)
                    .foregroundColor(Color.Codive.grayscale1)
                
                Text("확인 및 조치는 영업일 기준 3~5일정도 소요됩니다.")
                    .font(.codive_body2_regular)
                    .foregroundColor(Color.Codive.grayscale1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.Codive.point4)
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        
        ReportSubmissionGuide()
            .padding(.horizontal, 20)
    }
}
