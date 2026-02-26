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

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundStyle(Color.Codive.grayscale6)

                    Rectangle()
                        .foregroundStyle(Color.Codive.point1)
                        .frame(width: geometry.size.width / 2)
                        .offset(x: selectedSegment == .account ? 0 : geometry.size.width / 2)
                }
            }
            .frame(height: 2)
        }
    }

    @ViewBuilder
    private func segmentItem(title: String, segment: SearchResultSegment) -> some View {
        Button {
            selectedSegment = segment
        } label: {
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
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
