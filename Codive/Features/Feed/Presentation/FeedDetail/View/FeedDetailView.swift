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
    @Environment(\.dismiss) private var dismiss
    
    // UI State
    @State private var currentImageIndex: Int = 0
    @State private var selectedTagId: UUID?
    @State private var showTagsAndThumbnails: Bool = true

    // For Previewing
    private let previewImages: [UIImage]?
    
    // MARK: - Initializer
    init(viewModel: FeedDetailViewModel, previewImages: [UIImage]? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.previewImages = previewImages
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }, label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                })
                
                Spacer()
                
                Text("기록 상세")
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
                            nickname: feed.author?.nickname ?? "Unknown User"
                        ) { }
                        
                        // 이미지 슬라이더
                        FeedImageSlider(
                            images: previewImages ?? [],
                            tags: feed.images.map { image in
                                image.tags.map { tag in
                                    ClothTag(
                                        id: tag.id,
                                        clothId: UUID(),
                                        brand: "Brand",
                                        name: "Product \(tag.clothId)",
                                        locationX: CGFloat(tag.locationX),
                                        locationY: CGFloat(tag.locationY)
                                    )
                                }
                            },
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
                        if showTagsAndThumbnails, feed.images.indices.contains(currentImageIndex) {
                            let currentTags = feed.images[currentImageIndex].tags
                            if !currentTags.isEmpty {
                                LinkedProductListView(
                                    tags: currentTags.map { tag in
                                        ClothTag(
                                            id: tag.id,
                                            clothId: UUID(),
                                            brand: "Brand",
                                            name: "Product \(tag.clothId)",
                                            locationX: CGFloat(tag.locationX),
                                            locationY: CGFloat(tag.locationY)
                                        )
                                    },
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
                            date: feed.createdAt?.description ?? "Date N/A",
                            styles: []
                        ) {
                            Task { await viewModel.toggleLike() }
                        }
                    } else if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        Text(viewModel.errorMessage ?? "정보를 불러올 수 없습니다.")
                            .padding(.top, 50)
                    }
                }
            }
        }
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
    let viewModel = FeedDIContainer.makeFeedDetailViewModelForPreview(
        feedId: 1,
        repository: mockRepo
    )
    
    FeedDetailView(
        viewModel: viewModel,
        previewImages: [UIImage(systemName: "photo.artframe")!]
    )
}
