//
//  HashtagView.swift
//  Codive
//
//  Created by 한금준 on 12/31/25.
//

import SwiftUI

// MARK: - Hashtag View
struct HashtagView: View {
    @ObservedObject var viewModel: SearchResultViewModel
    
    // MARK: - Computed Properties
    private var sortOptionsString: [String] {
        viewModel.sortOptions.map { $0.displayName }
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Text("\(TextLiteral.Search.totalCount) \(viewModel.posts.count)\(TextLiteral.Search.countUnit)")
                    .font(Font.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale3)
                Spacer()

                SortOption(
                    mainText: TextLiteral.Search.sortAll,
                    options: sortOptionsString,
                    selectedOption: $viewModel.currentSort
                )
                .zIndex(10)
            }
            .padding(.top, 18)
            .zIndex(10)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 11) {
                ForEach(viewModel.posts) { post in
                    Button {
                        viewModel.navigateToFeedDetail(feedId: post.id)
                    } label: {
                        PostCard(
                            postImageUrl: post.postImageUrl,
                            profileImageUrl: post.profileImageUrl,
                            nickname: post.nickname
                        )
                    }
                }
            }
            .padding(.top, 18)
            .zIndex(1)
        }
        .padding(.bottom, 20)
    }
}
