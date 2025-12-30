//
//  ReportSubmissionGuide.swift
//  Codive
//
//  Created by 한금준 on 12/30/25.
//

import SwiftUI

struct ReportSubmissionGuide: View {
    let reportType: ReportType
    
    // 타입에 따른 안내 문구 결정
    private var reportTargetText: String {
        switch reportType {
        case .feed:
            return "게시글이"
        case .comment:
            return "댓글이"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Image("warning")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.Codive.point1)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("신고 접수 안내")
                        .font(.codive_body1_medium)
                        .foregroundColor(Color.Codive.grayscale1)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // 동적 텍스트 적용
                Text("회원님의 \(reportTargetText) 운영 정책 위반으로 신고되었습니다.")
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
    VStack {
        ReportSubmissionGuide(reportType: .comment)
            .padding(.horizontal, 20)
        
        ReportSubmissionGuide(reportType: .feed)
            .padding(.horizontal, 20)
    }
}
