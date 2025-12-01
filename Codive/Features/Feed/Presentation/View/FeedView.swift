//
//  FeedView.swift
//  Codive
//
//  Created by 황상환 on 2025/12/01.
//

import SwiftUI

struct FeedView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: FeedViewModel
    
    // Filter States
    @State private var isFollowingSelected: Bool = false
    @State private var selectedCategory: String = ""
    
    init(viewModel: FeedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 11),
        GridItem(.flexible(), spacing: 11)
    ]
    
    private let styleCategories = [
        TextLiteral.Add.styleCasual,
        TextLiteral.Add.styleLoving,
        TextLiteral.Add.styleMinimal,
        TextLiteral.Add.styleVintage,
        TextLiteral.Add.styleSporty,
        TextLiteral.Add.styleStreet,
        TextLiteral.Add.styleChic,
        TextLiteral.Add.styleOffice,
        TextLiteral.Add.styleClassic,
        TextLiteral.Add.styleHighteen
    ]
    
    // MARK: - Body
    var body: some View {
        VStack {
            FeedFilterBar(
                isFollowingSelected: $isFollowingSelected,
                categories: styleCategories,
                selectedCategory: $selectedCategory,
                onFilterTap: {
                    // TODO: Implement filter sheet presentation
                }
            )
            
            feedGrid
        }
        .onChange(of: isFollowingSelected, perform: { newValue in
            viewModel.followingOnly = newValue
            Task {
                await viewModel.applyFilters()
            }
        })
        .onChange(of: selectedCategory, perform: { newValue in
            Task {
                await viewModel.applyFilters()
            }
        })
        .task {
            if viewModel.feeds.isEmpty {
                await viewModel.loadFeeds()
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var feedGrid: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.feeds.isEmpty {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .padding()
            } else {
                feedLazyVGrid
            }
        }
    }

    @ViewBuilder
    private var feedLazyVGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.feeds) { feed in
                FeedCellView(feed: feed, viewModel: viewModel)
            }
        }
        .padding(.horizontal, 20)
//        .padding(.top, 8)
    }
}

// MARK: - FeedCellView
private struct FeedCellView: View {
    let feed: Feed
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        CustomFeedCard(
            imageUrl: feed.images.first?.imageUrl ?? "",
            profileImageUrl: feed.author?.profileImageUrl ?? "sample_profile",
            nickname: feed.author?.nickname ?? "Unknown",
            isLiked: Binding(
                get: { feed.isLiked ?? false },
                set: { _ in
                    Task {
                        await viewModel.toggleLike(feedId: feed.id)
                    }
                }
            )
        )
        .onAppear {
            // Simple pagination trigger
            if feed.id == viewModel.feeds.last?.id {
                Task {
                    await viewModel.loadMoreFeeds()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let feedDIContainer = FeedDIContainer()
    let viewModel = feedDIContainer.makeFeedViewModel()
    
    return NavigationStack {
        FeedView(viewModel: viewModel)
    }
}
