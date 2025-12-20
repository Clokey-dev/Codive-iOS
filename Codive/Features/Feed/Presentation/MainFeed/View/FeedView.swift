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
    private let feedDIContainer: FeedDIContainer

    // MARK: Filter States
    // Top Bar States
    @State private var isFollowingSelected: Bool = false
    @State private var selectedCategory: String = ""

    // Bottom Sheet States
    @State private var isShowingFilterSheet: Bool = false
    @State private var selectedSheetStyles: Set<String> = []
    @State private var selectedSheetSituations: Set<String> = []

    init(viewModel: FeedViewModel, feedDIContainer: FeedDIContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.feedDIContainer = feedDIContainer
    }

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 11),
        GridItem(.flexible(), spacing: 11)
    ]
    
    private let styleCategories = [
        TextLiteral.Add.styleCasual, TextLiteral.Add.styleLoving, TextLiteral.Add.styleMinimal,
        TextLiteral.Add.styleVintage, TextLiteral.Add.styleSporty, TextLiteral.Add.styleStreet,
        TextLiteral.Add.styleChic, TextLiteral.Add.styleOffice, TextLiteral.Add.styleClassic,
        TextLiteral.Add.styleHighteen
    ]
    
    // MARK: - Body
    var body: some View {
        VStack {
            FeedFilterBar(
                isFollowingSelected: $isFollowingSelected,
                categories: styleCategories,
                selectedCategory: $selectedCategory
            ) {
                isShowingFilterSheet = true
            }

            feedGrid
        }
        .onChange(of: isFollowingSelected) { newValue in
            viewModel.followingOnly = newValue
            Task { await viewModel.applyFilters() }
        }
        .onChange(of: selectedCategory) { _ in
            viewModel.selectedStyleIds = nil
            viewModel.selectedSituationIds = nil
            Task { await viewModel.applyFilters() }
        }
        .sheet(isPresented: $isShowingFilterSheet) {
            FeedFilterBottomSheet(
                selectedStyles: $selectedSheetStyles,
                selectedSituations: $selectedSheetSituations
            ) {
                selectedSheetStyles.removeAll()
                selectedSheetSituations.removeAll()
            } onApply: {
                isShowingFilterSheet = false
                Task { await viewModel.applyFilters() }
            }
            .presentationDetents([.height(500)])
        }
        .task {
            if viewModel.feeds.isEmpty {
                await viewModel.loadFeeds()
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var feedGrid: some View {
        Group {
            if viewModel.isLoading && viewModel.feeds.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.feeds.isEmpty {
                if viewModel.followingOnly {
                    FeedEmptyView(type: .noFollowing) {
                        viewModel.browseAllFeeds()
                        isFollowingSelected = false
                    }
                } else {
                    FeedEmptyView(type: .noFeeds) {
                        viewModel.clearFiltersAndReload()
                        selectedCategory = ""
                    }
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .padding()
            } else {
                ScrollView {
                    feedLazyVGrid
                }
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
    }
}

// MARK: - FeedCellView
private struct FeedCellView: View {
    let feed: Feed
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        Button {
            viewModel.navigateToDetail(feedId: feed.id)
        } label: {
            CustomFeedCard(
                imageUrl: feed.images.first?.imageUrl ?? "",
                profileImageUrl: feed.author.profileImageUrl ?? "sample_profile",
                nickname: feed.author.nickname,
                isLiked: Binding(
                    get: { feed.isLiked ?? false },
                    set: { _ in
                        Task {
                            await viewModel.toggleLike(feedId: feed.id)
                        }
                    }
                )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if feed.id == viewModel.feeds.last?.id {
                Task {
                    await viewModel.loadMoreFeeds()
                }
            }
        }
    }
}

// MARK: - Preview
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        // MARK: - Helper to create FeedDIContainer
        @MainActor
        func makeFeedDIContainer(dataSource: FeedDataSource) -> FeedDIContainer {
            let appDIContainer = AppDIContainer()
            let feedDIContainer = appDIContainer.makeFeedDIContainer()
            return feedDIContainer
        }

        // Default: Uses mock data
        let defaultContainer = makeFeedDIContainer(dataSource: MockFeedDataSource())
        let defaultVM = defaultContainer.makeFeedViewModel()

        // Empty (No Following): Uses empty data source
        let noFollowingContainer = makeFeedDIContainer(dataSource: EmptyFeedDataSource())
        let noFollowingVM = noFollowingContainer.makeFeedViewModel()
        noFollowingVM.followingOnly = true

        // Empty (No Feeds): Uses empty data source
        let noFeedsContainer = makeFeedDIContainer(dataSource: EmptyFeedDataSource())
        let noFeedsVM = noFeedsContainer.makeFeedViewModel()

        return Group {
            FeedView(viewModel: defaultVM, feedDIContainer: defaultContainer)
                .previewDisplayName("Default")

            FeedView(viewModel: noFollowingVM, feedDIContainer: noFollowingContainer)
                .previewDisplayName("Empty (No Following)")

            FeedView(viewModel: noFeedsVM, feedDIContainer: noFeedsContainer)
                .previewDisplayName("Empty (No Feeds)")
        }
    }
}
