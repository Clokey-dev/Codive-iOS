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
    
    // UI Interactions
    @State private var currentImageIndex: Int = 0
    @State private var selectedTagId: UUID? // 썸네일 선택 상태 관리
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
                
                Spacer()
                
                Text("기록 상세")
                    .font(.codive_title2) // or .headline
                    .foregroundStyle(.black)
                
                Spacer()
                
                // 센터 정렬을 위한 더미
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // 2. Main Scroll View
            ScrollView {
                VStack(spacing: 0) {
                    
                    if let feed = viewModel.feed {
                        // (1) 프로필 헤더
                        ProfileHeaderView(
                            profileImageUrl: feed.author?.profileImageUrl ?? "",
                            nickname: feed.author?.nickname ?? "Unknown User",
                            onMoreTap: {
                                // 더보기 액션
                            }
                        )
                        
                        // (2) 이미지 슬라이더
                        FeedImageSlider(
                            images: [], // viewModel에서 로드된 이미지 배열 연결 필요
                            tags: feed.images.map { image in
                                image.tags.map { tag in
                                    ClothTag(
                                        id: tag.id,
                                        clothId: UUID(), // TODO: Resolve Int vs UUID mismatch
                                        brand: "Unknown Brand", // TODO: Fetch real brand name
                                        name: "Unknown Name", // TODO: Fetch real cloth name
                                        locationX: CGFloat(tag.locationX),
                                        locationY: CGFloat(tag.locationY)
                                    )
                                }
                            },
                            currentIndex: $currentImageIndex
                        )
                        
                        // (3) 연동 상품 썸네일 리스트
                        if feed.images.indices.contains(currentImageIndex) {
                            let currentTags = feed.images[currentImageIndex].tags
                            if !currentTags.isEmpty {
                                LinkedProductListView(
                                    tags: currentTags.map { tag in
                                        ClothTag(
                                            id: tag.id,
                                            clothId: UUID(), // TODO: Resolve Int vs UUID mismatch
                                            brand: "Unknown Brand", // TODO: Fetch real brand name
                                            name: "Unknown Name", // TODO: Fetch real cloth name
                                            locationX: CGFloat(tag.locationX),
                                            locationY: CGFloat(tag.locationY)
                                        )
                                    },
                                    selectedTagId: $selectedTagId
                                )
                            }
                        }
                        
                        // (4) 컨텐츠 섹션 (좋아요, 본문, 태그 등)
                        FeedContentSection(
                            likeCount: feed.likeCount ?? 0,
                            commentCount: feed.commentCount ?? 0,
                            isLiked: feed.isLiked ?? false,
                            content: feed.content ?? "",
                            hashtags: feed.hashtags ?? [],
                            date: feed.createdAt?.description ?? "Date N/A", // TODO: 날짜 포맷팅 필요
                            styles: [], // TODO: feed.styleIds를 이름으로 변환하는 로직 필요
                            onLikeTap: {
                                Task { await viewModel.toggleLike() }
                            }
                        )
                    } else if viewModel.isLoading {
                        // 로딩 뷰
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        // 에러 또는 빈 상태
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

// MARK: - Subviews

// 1. 프로필 헤더
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
                    // Image(profileImageUrl) ...
                    Image(systemName: "person.crop.circle.fill") // 임시
                        .resizable()
                        .foregroundStyle(Color.gray)
                )
                .clipShape(Circle())
            
            Text(nickname)
                .font(.codive_body2_medium) // or system(14, medium)
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

// 컨텐츠 섹션 (본문, 버튼 등)
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
                        // Tuist Asset 사용: CodiveAsset.heartOn : CodiveAsset.heartOff
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
            // 디자인에 있는 "미니멀", "데일리" 같은 고정 태그들
            HStack(spacing: 8) {
                // 임시 데이터: 실제로는 feed.styles 등을 사용
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

// Mock for FetchFeedDetailUseCase
private class MockFetchFeedDetailUseCase: FetchFeedDetailUseCase {
    var resultFeed: Feed // Customizable feed for preview

    init(resultFeed: Feed) {
        self.resultFeed = resultFeed
    }

    func execute(feedId: Int) async throws -> Feed {
        return resultFeed
    }
}

// Mock for FeedRepository
private class MockFeedRepository: FeedRepository {
    var resultFeed: Feed // Customizable feed for preview

    init(resultFeed: Feed) {
        self.resultFeed = resultFeed
    }

    func fetchFeeds(page: Int, limit: Int, styleIds: [Int]?, situationIds: [Int]?, followingOnly: Bool) async throws -> [Feed] {
        return [] // Not used in this preview
    }

    func fetchFeedDetail(id: Int) async throws -> Feed {
        return resultFeed
    }

    func toggleLike(feedId: Int) async throws {
        // Do nothing for preview
    }
}

#Preview {
    // Dummy Data for Feed
    let dummyUser = User(id: "abc", nickname: "테스트 유저", profileImageUrl: nil)
    let dummyImageTags: [ImageClothTag] = [
        ImageClothTag(clothId: 101, locationX: 0.2, locationY: 0.3),
        ImageClothTag(clothId: 102, locationX: 0.7, locationY: 0.8)
    ]
    let dummyFeedImage = FeedImage(imageUrl: "https://example.com/image.jpg", tags: dummyImageTags)
    let dummyFeed = Feed(
        id: 1,
        content: "이것은 프리뷰용 테스트 피드 내용입니다. 코디가 아주 멋지네요!",
        author: dummyUser,
        images: [dummyFeedImage], // Providing a dummy image for the slider
        situationId: 1,
        styleIds: [1, 2],
        hashtags: ["데일리룩", "OOTD", "코디추천"],
        createdAt: Date(),
        likeCount: 15,
        isLiked: true,
        commentCount: 5
    )

    // Setup Mocks
    let mockFeedRepository = MockFeedRepository(resultFeed: dummyFeed)
    let mockFetchFeedDetailUseCase = MockFetchFeedDetailUseCase(resultFeed: dummyFeed)

    // Instantiate ViewModel
    let viewModel = FeedDetailViewModel(
        feedId: 1,
        fetchFeedDetailUseCase: mockFetchFeedDetailUseCase,
        feedRepository: mockFeedRepository
    )

    FeedDetailView(viewModel: viewModel)
}