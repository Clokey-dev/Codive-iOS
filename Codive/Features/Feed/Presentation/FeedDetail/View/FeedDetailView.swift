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
    
    @State private var currentImageIndex: Int = 0
    @State private var selectedTagId: UUID?
    @State private var showTagsAndThumbnails: Bool = true

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
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
                
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
                            nickname: feed.author?.nickname ?? "Unknown User",
                            onMoreTap: { }
                        )
                        
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
                            styles: [],
                            onLikeTap: {
                                Task { await viewModel.toggleLike() }
                            }
                        )
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

// MARK: - Subviews (코드 유지)
private struct ProfileHeaderView: View {
    let profileImageUrl: String
    let nickname: String
    let onMoreTap: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // 프로필 이미지
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundStyle(Color.gray)
                )
                .clipShape(Circle())
            
            Text(nickname)
                .font(.codive_body2_medium) 
                .foregroundStyle(Color.Codive.grayscale1)
            
            Spacer()
            
            Button(action: onMoreTap) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundStyle(Color.Codive.grayscale3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

private struct FeedContentSection: View {
    let likeCount: Int
    let commentCount: Int
    let isLiked: Bool
    let content: String
    let hashtags: [String]
    let date: String
    let styles: [String]
    let onLikeTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: onLikeTap) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(isLiked ? Color.red : Color.black)
                        Text("\(likeCount)")
                            .font(.codive_body2_regular)
                            .foregroundStyle(Color.black)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right") // message icon
                    Text("\(commentCount)")
                        .font(.codive_body2_regular)
                        .foregroundStyle(Color.black)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Caption
            Text(content)
                .font(.codive_body2_regular)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            
            // Hashtags
            if !hashtags.isEmpty {
                Text(hashtags.map { "#\($0)" }.joined(separator: " "))
                    .font(.codive_body2_regular)
                    .foregroundStyle(Color.Codive.point1) // Orange
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }
            
            // Date
            Text(date)
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale3)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            
            // Divider
            Rectangle()
                .fill(Color.Codive.grayscale5) // 연한 회색
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // Fixed Filter Tags (Chips)
            HStack(spacing: 8) {
                ForEach(["미니멀", "데일리"], id: \.self) { style in
                    Text(style)
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.Codive.grayscale4, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Preview
private final class PreviewMockFeedRepository: FeedRepository {

    var resultFeed: Feed

    init() {

        let dummyUser = User(id: "previewUser", nickname: "프리뷰 유저", profileImageUrl: nil)

        // 하나의 이미지에 여러개의 태그 생성
        let dummyImageTags: [ImageClothTag] = [
            ImageClothTag(clothId: 101, locationX: 0.25, locationY: 0.3),
            ImageClothTag(clothId: 102, locationX: 0.75, locationY: 0.5),
            ImageClothTag(clothId: 103, locationX: 0.5, locationY: 0.75)
        ]

        let dummyFeedImage = FeedImage(imageUrl: "https://example.com/image.jpg", tags: dummyImageTags)

        self.resultFeed = Feed(
            id: 1,
            content: "이것은 프리뷰용 테스트 피드 내용입니다. 코디가 아주 멋지네요!",
            author: dummyUser,
            images: [dummyFeedImage], // 이미지는 하나, 태그는 여러개
            situationId: 1,
            styleIds: [1, 2],
            hashtags: ["#미리보기", "#OOTD"],
            createdAt: Date(),
            likeCount: 99,
            isLiked: true,
            commentCount: 9
        )
    }

    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return []
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        return resultFeed
    }

    func toggleLike(feedId: Int) async throws {
        let newIsLiked = !(resultFeed.isLiked ?? false)
        let newLikeCount = newIsLiked ? (resultFeed.likeCount ?? 0) + 1 : (resultFeed.likeCount ?? 1) - 1

        // Feed 초기화 시 모든 파라미터를 전달하도록 수정
        resultFeed = Feed(
            id: resultFeed.id,
            content: resultFeed.content,
            author: resultFeed.author,
            images: resultFeed.images,
            situationId: resultFeed.situationId,
            styleIds: resultFeed.styleIds,
            hashtags: resultFeed.hashtags,
            createdAt: resultFeed.createdAt,
            likeCount: newLikeCount,
            isLiked: newIsLiked,
            commentCount: resultFeed.commentCount
        )
    }
}

/// 프리뷰용 FetchFeedDetailUseCase
private final class PreviewFetchFeedDetailUseCase: FetchFeedDetailUseCase {
    private let repository: FeedRepository

    init(repository: FeedRepository) {
        self.repository = repository
    }

    func execute(feedId: Int) async throws -> Feed {
        try await repository.fetchFeedDetail(id: feedId)
    }
}

#Preview {
    // 1. Mock Repository 및 UseCase 생성
    let mockRepo = PreviewMockFeedRepository()
    let mockUseCase = PreviewFetchFeedDetailUseCase(repository: mockRepo)
    // 2. ViewModel 생성
    let viewModel = FeedDetailViewModel(
        feedId: 1,
        fetchFeedDetailUseCase: mockUseCase,
        feedRepository: mockRepo
    )
    // 3. View에 ViewModel 및 프리뷰용 더미 이미지 주입
    FeedDetailView(
        viewModel: viewModel,
        previewImages: [UIImage(systemName: "photo.artframe")!]
    )
}
