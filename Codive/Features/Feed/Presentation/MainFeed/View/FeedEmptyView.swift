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
            return "팔로잉한 사람이 아직 없어요."
        case .noFeeds:
            return "관련된 스타일 피드가 아직 없어요."
        }
    }
    
    private var subtitle: String {
        switch type {
        case .noFollowing:
            return "관심있는 사람을 팔로잉하면\n그들의 스타일을 모아볼 수 있어요."
        case .noFeeds:
            return "곧 다양한 코디가\n이 스타일 피드에 올려질 예정이에요!"
        }
    }
    
    private var buttonText: String {
        switch type {
        case .noFollowing:
            return "지금 둘러보기"
        case .noFeeds:
            return "다른 스타일 보기"
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
