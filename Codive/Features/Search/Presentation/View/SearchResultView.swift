//
//  SearchResultView.swift
//  Codive
//
//  Created by 한금준 on 11/19/25.
//

import SwiftUI

// MARK: - Segment Type
enum SearchResultSegment {
    case account
    case hashtag
}

// MARK: - Search Result
struct SearchResultView: View {
    // MARK: - Properties
    @StateObject private var viewModel: SearchResultViewModel
    @State private var selectedSegment: SearchResultSegment = .account
    
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
            .padding(.horizontal, 20)
            .zIndex(1)
            .onSubmit {
                viewModel.executeNewSearch(query: viewModel.searchBarText)
            }
            
            SearchResultSegmentControl(selectedSegment: $selectedSegment)
                .padding(.top, 8)
            
            ScrollView {
                // MARK: - Account Result List
                if selectedSegment == .account {
                    VStack(spacing: 0) {
                        ForEach(viewModel.users, id: \.userId) { user in
                            CustomUserRow(
                                user: user,
                                buttonStyle: .none
                            ) {
                                // 버튼 동작
                            }
                        }
                    }
                    .padding(.top, 18)
                } else {
                    // MARK: - Hashtag Result Grid
                    Hashtag(viewModel: viewModel)
                        .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea(.all))
        // MARK: - Data Loading Trigger
        .onAppear {
            viewModel.loadInitialData()
        }
    }
}

// MARK: - Hashtag View
struct Hashtag: View {
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
