//
//  SearchResultView.swift
//  Codive
//
//  Created by 한금준 on 11/19/25.
//

import SwiftUI

struct SearchResultView: View {
    // MARK: - Properties
    @StateObject private var viewModel: SearchResultViewModel
    
    // MARK: - Computed Properties
    private var sortOptionsString: [String] {
        viewModel.sortOptions.map { $0.displayName }
    }
    
    // MARK: - Initializer
    init(viewModel: SearchResultViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            CustomSearchBar(
                text: $viewModel.searchBarText,
                type: .withBackButton {
                    viewModel.handleBackTap()
                }
            )
            .zIndex(1)
            .onSubmit {
                viewModel.executeNewSearch(query: viewModel.searchBarText)
            }
            
            ScrollView {
                VStack {
                    HStack {
                        Text("총 \(viewModel.posts.count)개")
                            .font(Font.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale3)
                        Spacer()
                        
                        SortOption(
                            mainText: "전체",
                            options: sortOptionsString,
                            selectedOption: $viewModel.currentSort
                        )
                        .zIndex(10)
                    }
                    .padding(.top, 18)
                    .zIndex(10)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 11) {
                        ForEach(viewModel.posts) { post in
                            PostCard(
                                postImageUrl: post.postImageUrl,
                                profileImageUrl: post.profileImageUrl,
                                nickname: post.nickname
                            )
                        }
                    }
                    .padding(.top, 18)
                    .zIndex(1)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea(.all))
        .padding(.horizontal, 20)
    }
}

