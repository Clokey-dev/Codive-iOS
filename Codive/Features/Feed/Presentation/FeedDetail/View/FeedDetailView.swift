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
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                CustomNavigationBar(title: TextLiteral.Feed.detailTitle) {
                    navigationRouter.navigateBack()
                }

                ScrollView {
                    VStack(spacing: 0) {
                        if let feed = viewModel.feed {
                        // 프로필
                        ProfileHeaderView(
                            profileImageUrl: feed.author.profileImageUrl ?? "",
                            nickname: feed.author.nickname,
                            onMoreTap: {
                                viewModel.showMoreMenu()
                            },
                            onProfileTap: {
                                viewModel.navigateToProfile(userId: feed.author.id, isMine: feed.author.isMe ?? false)
                            }
                        )
                        
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

            // 로딩 인디케이터
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.5)
                    .zIndex(100)
            }

            // 더보기 메뉴 오버레이
            if viewModel.isMoreMenuPresented, let feed = viewModel.feed {
                ZStack(alignment: .topTrailing) {
                    Color.black
                        .opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.dismissMoreMenu()
                        }

                    if feed.author.isMe ?? false {
                        // 내 피드: 수정하기, 삭제하기
                        CustomOverflowMenu(
                            menuType: .closet,
                            menuActions: [
                                { viewModel.onEditTapped() },
                                { viewModel.onDeleteTapped() }
                            ],
                            isExpanded: viewModel.isMoreMenuPresented,
                            showButton: false
                        , onClose: { viewModel.dismissMoreMenu() })
                        .padding(.trailing, 20)
                        .padding(.top, 80)
                    } else {
                        // 다른 사람 피드: 신고하기, 차단하기
                        CustomOverflowMenu(
                            menuType: .report,
                            menuActions: [
                                { viewModel.onReportTapped() },
                                { viewModel.onBlockTapped() }
                            ],
                            isExpanded: viewModel.isMoreMenuPresented,
                            showButton: false,
                            onClose: { viewModel.dismissMoreMenu() })
                        .padding(.trailing, 20)
                        .padding(.top, 80)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(10)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .enableSwipeBack()
        .onAppear {
            Task {
                await viewModel.loadFeedDetail()
            }
        }
        .sheet(isPresented: $viewModel.isLikesSheetPresented) {
            FeedLikesListView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: Binding(
            get: { navigationRouter.sheetDestination != nil && isCommentSheet(navigationRouter.sheetDestination) },
            set: { if !$0 { navigationRouter.dismissSheet() } }
        ), onDismiss: {
            Task {
                await viewModel.loadFeedDetail()
            }
        }) {
            if case .comment(let feedId) = navigationRouter.sheetDestination {
                commentDIContainer.commentViewFactory.makeView(for: .comment(feedId: feedId))
                    .presentationDetents([.fraction(0.7), .large])
            }
        }
        .alert("기록 삭제", isPresented: $viewModel.showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                viewModel.confirmDelete()
            }
        } message: {
            Text("이 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.")
        }
        .alert("사용자 차단", isPresented: $viewModel.showBlockAlert) {
            Button("취소", role: .cancel) { }
            Button("차단", role: .destructive) {
                viewModel.confirmBlock()
            }
        } message: {
            if let feed = viewModel.feed {
                Text("\(feed.author.nickname)님을 차단하시겠습니까?\n차단된 사용자의 기록을 더 이상 볼 수 없습니다.")
            }
        }
        .alert("차단 실패", isPresented: $viewModel.showBlockFailureAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.blockErrorMessage)
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidBlock)) { _ in
            // 댓글에서 차단한 경우: 피드 상세 다시 로드 시도
            // 기록 주인이 차단된 경우 API 에러 → 뒤로가기
            Task {
                await viewModel.loadFeedDetail()
                if viewModel.feed == nil {
                    navigationRouter.navigateBack()
                }
            }
        }
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

#if DEBUG
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
#endif
