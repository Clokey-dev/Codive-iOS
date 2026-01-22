//
//  FeedDetailView.swift
//  Codive
//
//  Created by 황상환 on 12/3/25.
//

import SwiftUI

struct FeedDetailView: View {

    // MARK: - Properties
    @StateObject var viewModel: FeedDetailViewModel
    @ObservedObject var navigationRouter: NavigationRouter
    let commentDIContainer: CommentDIContainer

    // UI State
    @State private var currentImageIndex: Int = 0
    @State private var selectedTagId: UUID?
    @State private var showTagsAndThumbnails: Bool = false

    // MARK: - Initializer
    init(
        viewModel: FeedDetailViewModel,
        navigationRouter: NavigationRouter,
        commentDIContainer: CommentDIContainer
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _navigationRouter = ObservedObject(wrappedValue: navigationRouter)
        self.commentDIContainer = commentDIContainer
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    navigationRouter.navigateBack()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                })
                
                Spacer()
                
                Text(TextLiteral.Feed.detailTitle)
                    .font(.codive_title2)
                    .foregroundStyle(.black)
                
                Spacer()
                
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            ScrollView {
                VStack(spacing: 0) {
                    if let feed = viewModel.feed {
                        // 프로필
                        ProfileHeaderView(
                            profileImageUrl: feed.author.profileImageUrl ?? "",
                            nickname: feed.author.nickname
                        ) { }
                        
                        // 이미지 슬라이더
                        FeedImageSlider(
                            imageUrls: viewModel.imageUrls,
                            tags: viewModel.displayableTags,
                            currentIndex: $currentImageIndex,
                            showTags: showTagsAndThumbnails,
                            selectedTagId: selectedTagId,
                            onTagButtonTap: {
                                showTagsAndThumbnails.toggle()
                            },
                            onTagTap: { tagId in
                                if selectedTagId == tagId {
                                    selectedTagId = nil
                                } else {
                                    selectedTagId = tagId
                                }
                            }
                        )
                        
                        // 연동 상품 썸네일 리스트
                        if showTagsAndThumbnails, viewModel.displayableTags.indices.contains(currentImageIndex) {
                            let currentTags = viewModel.displayableTags[currentImageIndex]
                            if !currentTags.isEmpty {
                                LinkedProductListView(
                                    tags: currentTags,
                                    selectedTagId: $selectedTagId
                                )
                            }
                        }
                        
                        // 컨텐츠 섹션
                        FeedContentSection(
                            likeCount: feed.likeCount ?? 0,
                            commentCount: feed.commentCount ?? 0,
                            isLiked: feed.isLiked ?? false,
                            content: feed.content ?? "",
                            hashtags: feed.hashtags ?? [],
                            date: viewModel.formattedDate,
                            styles: viewModel.displayableStyles,
                            onLikeTap: {
                                Task { await viewModel.toggleLike() }
                            },
                            onCommentTap: {
                                viewModel.commentButtonTapped()
                            },
                            onLikesCountTap: {
                                viewModel.likesCountTapped()
                            }
                        )
                    } else if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        Text(viewModel.errorMessage ?? TextLiteral.Feed.genericLoadFailed)
                            .padding(.top, 50)
                    }
                }
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.loadFeedDetail()
            }
        }
        .sheet(isPresented: $viewModel.isLikesSheetPresented, onDismiss: {
            viewModel.isLikesSheetPresented = false
        }, content: {
            FeedLikesListView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        })
        .sheet(isPresented: Binding(
            get: { navigationRouter.sheetDestination != nil && isCommentSheet(navigationRouter.sheetDestination) },
            set: { if !$0 { navigationRouter.dismissSheet() } }
        ), content: {
            if case .comment(let feedId) = navigationRouter.sheetDestination {
                commentDIContainer.commentViewFactory.makeView(for: .comment(feedId: feedId))
            }
        })
    }

    // MARK: - Helper Methods

    private func isCommentSheet(_ destination: AppDestination?) -> Bool {
        guard let destination = destination else { return false }
        if case .comment = destination {
            return true
        }
        return false
    }
}

// MARK: - Preview
#Preview {

    let mockRepo = MockFeedRepository()
    let navigationRouter = NavigationRouter()
    let viewModel = FeedDIContainer.makeFeedDetailViewModelForPreview(
        feedId: 1,
        repository: mockRepo,
        navigationRouter: navigationRouter
    )

    FeedDetailView(
        viewModel: viewModel,
        navigationRouter: navigationRouter,
        commentDIContainer: CommentDIContainer(navigationRouter: navigationRouter)
    )
}
