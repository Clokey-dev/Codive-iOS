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

    // UI State
    @State private var currentImageIndex: Int = 0
    @State private var selectedTagId: UUID?
    @State private var showTagsAndThumbnails: Bool = false

    // For Previewing
    private let previewImages: [UIImage]?

    // MARK: - Initializer
    init(
        viewModel: FeedDetailViewModel,
        navigationRouter: NavigationRouter,
        previewImages: [UIImage]? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _navigationRouter = ObservedObject(wrappedValue: navigationRouter)
        self.previewImages = previewImages
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
                            profileImageUrl: feed.author?.profileImageUrl ?? "",
                            nickname: feed.author?.nickname ?? TextLiteral.Common.unknownUser
                        ) { }
                        
                        // 이미지 슬라이더
                        FeedImageSlider(
                            images: previewImages ?? [],
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
                            styles: viewModel.displayableStyles
                        ) {
                            Task { await viewModel.toggleLike() }
                        }
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
    }
}

// MARK: - Preview
#Preview {

    let mockRepo = MockFeedRepository()
    let navigationRouter = NavigationRouter()
    let viewModel = FeedDIContainer.makeFeedDetailViewModelForPreview(
        feedId: 1,
        repository: mockRepo
    )

    FeedDetailView(
        viewModel: viewModel,
        navigationRouter: navigationRouter,
        previewImages: [UIImage(systemName: "photo.artframe")!]
    )
}
