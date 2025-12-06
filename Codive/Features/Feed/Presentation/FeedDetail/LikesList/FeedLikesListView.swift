//
//  FeedLikesListView.swift
//  Codive
//
//  Created by 황상환 on 2025/12/06.
//

import SwiftUI

struct FeedLikesListView: View {
    @ObservedObject var viewModel: FeedDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Spacer()
                Text(TextLiteral.LikesList.title)
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color.Codive.grayscale1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider().overlay(Color.Codive.grayscale6)
            
            // MARK: - Likers List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    if viewModel.likers.isEmpty {
                        Text(TextLiteral.LikesList.empty)
                            .foregroundStyle(Color.Codive.grayscale3)
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(viewModel.likers) { user in
                            CustomUserRow(
                                user: SimpleUser(
                                    userId: Int(user.id) ?? 0,
                                    nickname: user.nickname ?? TextLiteral.LikesList.anonymous,
                                    handle: "ID", // User 모델에 handle이 없으므로 임시값 사용
                                    avatarURL: URL(string: user.profileImageUrl ?? "")
                                ),
                                buttonTitle: (user.isFollowing ?? false) ? TextLiteral.LikesList.following : TextLiteral.LikesList.follow,
                                buttonStyle: (user.isFollowing ?? false) ? .secondary : .primary
                            ) {
                                // TODO: 팔로우/언팔로우 액션 구현
                                print("팔로우/언팔로우 \(user.nickname ?? "")")
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .background(Color.white)
    }
}

// MARK: - Preview
struct FeedLikesListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockRepo = MockFeedRepository()
        let appDIContainer = AppDIContainer() // Preview를 위해 임시 생성
        let navigationRouter = NavigationRouter()
        let viewModel = FeedDIContainer.makeFeedDetailViewModelForPreview(
            feedId: 1,
            repository: mockRepo,
            navigationRouter: navigationRouter
        )
        
        // 프리뷰용 목 데이터 설정
        viewModel.likers = [
            User(id: "1", nickname: "패셔니스타", profileImageUrl: nil, isFollowing: false),
            User(id: "2", nickname: "코디장인", profileImageUrl: nil, isFollowing: true),
            User(id: "3", nickname: "스타일헌터", profileImageUrl: nil, isFollowing: false)
        ]
        
        return FeedLikesListView(viewModel: viewModel)
    }
}
