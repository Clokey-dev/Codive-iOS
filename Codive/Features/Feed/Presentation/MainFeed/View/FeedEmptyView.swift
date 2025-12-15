//
//  FeedEmptyView.swift
//  Codive
//
//  Created by 황상환 on 2025/12/04.
//

import SwiftUI

enum FeedEmptyType {
    case noFollowing
    case noFeeds
}

struct FeedEmptyView: View {
    let type: FeedEmptyType
    let buttonAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                
                Text(subtitle)
                    .font(.codive_body2_regular)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 24)
            
            CustomButton(
                text: buttonText,
                widthType: .dynamic,
                styleType: buttonStyle,
                textColor: Color.white,
                action: buttonAction
            )
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var title: String {
        switch type {
        case .noFollowing:
            return TextLiteral.Feed.Empty.noFollowingTitle
        case .noFeeds:
            return TextLiteral.Feed.Empty.noFeedsTitle
        }
    }
    
    private var subtitle: String {
        switch type {
        case .noFollowing:
            return TextLiteral.Feed.Empty.noFollowingSubtitle
        case .noFeeds:
            return TextLiteral.Feed.Empty.noFeedsSubtitle
        }
    }
    
    private var buttonText: String {
        switch type {
        case .noFollowing:
            return TextLiteral.Feed.Empty.noFollowingButton
        case .noFeeds:
            return TextLiteral.Feed.Empty.noFeedsButton
        }
    }
    
    private var buttonStyle: ButtonStyleType {
        switch type {
        case .noFollowing:
            return .fill
        case .noFeeds:
            return .fill
        }
    }
}

#Preview {
    VStack {
        FeedEmptyView(type: .noFollowing, buttonAction: {})
        FeedEmptyView(type: .noFeeds, buttonAction: {})
    }
}
