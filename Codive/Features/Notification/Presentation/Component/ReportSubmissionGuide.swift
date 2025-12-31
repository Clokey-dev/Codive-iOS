//
//  ReportSubmissionGuide.swift
//  Codive
//
//  Created by 한금준 on 12/30/25.
//

import SwiftUI

struct ReportSubmissionGuide: View {
    let reportType: ReportType
    
    private var reportTargetText: String {
        switch reportType {
        case .feed:
            return TextLiteral.Notification.feedType
        case .comment:
            return TextLiteral.Notification.commentType
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
                
                Text(TextLiteral.Notification.reportTitle)
                    .font(.codive_body1_medium)
                    .foregroundColor(Color.Codive.grayscale1)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(TextLiteral.Notification.reportBody1(reportTargetText))
                    .font(.codive_body2_regular)
                    .foregroundColor(Color.Codive.grayscale1)
                
                Text(TextLiteral.Notification.reportBody2)
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
