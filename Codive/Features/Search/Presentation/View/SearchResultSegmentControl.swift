//
//  SearchResultSegmentControl.swift
//  Codive
//
//  Created by 한금준 on 12/31/25.
//

import SwiftUI

// MARK: - Segment Type
enum SearchResultSegment {
    case account
    case hashtag
}

// MARK: - Segment Control
struct SearchResultSegmentControl: View {
    @Binding var selectedSegment: SearchResultSegment
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                segmentItem(title: TextLiteral.Search.account, segment: .account)
                segmentItem(title: TextLiteral.Search.hashtag, segment: .hashtag)
            }
            
            Rectangle()
                .frame(height: 2)
                .foregroundStyle(Color.Codive.grayscale6)
        }
    }
    
    @ViewBuilder
    private func segmentItem(title: String, segment: SearchResultSegment) -> some View {
        Button {
            selectedSegment = segment
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(
                        selectedSegment == segment
                        ? .codive_body1_medium
                        : .codive_body1_regular
                    )
                    .foregroundStyle(
                        selectedSegment == segment
                        ? Color.Codive.grayscale1
                        : Color.Codive.grayscale4
                    )
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(
                        selectedSegment == segment
                        ? Color.Codive.point1
                        : .clear
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
