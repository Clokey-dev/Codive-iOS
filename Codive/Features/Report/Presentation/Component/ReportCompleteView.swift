//
//  ReportCompleteView.swift
//  Codive
//
//  Created by 한태빈 on 10/14/25.
//

import SwiftUI

struct ReportCompleteView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image("check")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            Text("신고가 접수되었습니다.")
                .font(Font.codive_title1)
                .foregroundStyle(Color.Codive.grayscale1)
        }
    }
}

#Preview {
    ReportCompleteView()
}
