//
//  ClosetView.swift
//  Codive
//
//  Created by 황상환 on 12/15/25.
//

import SwiftUI

struct ClosetView: View {
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                MyClosetSectionView()
                    .padding(.top, 15)
                
                WardrobeReportView()
                
                MyLookbookSectionView()
                Spacer(minLength: 45)
            }
        }
    }
}

#Preview {
    ClosetView()
}
