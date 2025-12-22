//
//  LookBookView.swift
//
//  Created by 한금준 on 11/27/25.
//  Codive
//

import SwiftUI

/// 룩북 메인 화면
/// - 역할:
///   - 룩북 목록을 그리드 형태로 표시
///   - 편집 모드(선택/삭제) 전환 처리
///   - 룩북 추가 다이얼로그 표시
///   - 특정 룩북 상세 화면으로 네비게이션
struct LookBookView: View {

    // MARK: - State & Dependencies

    /// 화면 상태 및 비즈니스 로직을 담당하는 ViewModel
    @StateObject private var viewModel: LookBookViewModel

    /// NavigationStack 경로를 관리하는 Router
    /// ViewModel에서 주입받아 동일한 네비게이션 상태를 공유한다.
    @ObservedObject private var navigationRouter: NavigationRouter

    /// LookBook 관련 View 생성을 담당하는 DI 컨테이너
    private let lookBookDIContainer: LookBookDIContainer

    // MARK: - Initializer

    init(
        viewModel: LookBookViewModel,
        lookBookDIContainer: LookBookDIContainer
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.navigationRouter = viewModel.navigationRouter
        self.lookBookDIContainer = lookBookDIContainer
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            ZStack {
                mainLayout
                addLookBookDialogOverlay

                if viewModel.isLoading {
                    LoadingView(backgroundStyle: .white)
                }
            }
            .navigationDestination(for: AppDestination.self) { destination in
                lookBookDIContainer
                    .lookBookViewFactory
                    .makeView(for: destination)
            }
            .navigationBarHidden(true)
            .background(Color.white)
            .alert(
                TextLiteral.LookBook.alertDeleteTitle,
                isPresented: $viewModel.isShowingDeleteAlert
            ) {
                Button(TextLiteral.Common.delete, role: .destructive) {
                    viewModel.beginDelete()
                }
                Button(TextLiteral.Common.cancel, role: .cancel) { }
            } message: {
                Text(TextLiteral.LookBook.alertDeleteSubTitle)
            }
            .alert(
                TextLiteral.LookBook.exitDescription,
                isPresented: $viewModel.isShowingCancelConfirmAlert
            ) {
                Button(TextLiteral.Home.leave, role: .destructive) {
                    viewModel.confirmCancelDialog()
                }
                Button(TextLiteral.Common.cancel, role: .cancel) { }
            } message: {
                Text(TextLiteral.LookBook.noRecovery)
            }
            .onAppear {
                if viewModel.lookBookList.isEmpty && !viewModel.isLoading {
                    viewModel.fetchLookBooks()
                }
            }
        }
    }

    // MARK: - Main Layout

    /// 상단 네비게이션 바 + 콘텐츠 영역
    private var mainLayout: some View {
        VStack(spacing: 0) {
            topBar
            contentArea
        }
    }

    // MARK: - Top Navigation Bar

    /// 상단 네비게이션 바
    /// - 기본 모드: 오버플로우 메뉴
    /// - 편집 모드: 삭제 완료 버튼
    private var topBar: some View {
        CustomNavigationBar(
            title: TextLiteral.LookBook.title,
            onBack: viewModel.handleBackTap,
            rightButton: viewModel.isEditing
            ? .text(
                title: TextLiteral.Common.delete,
                isEnabled: !viewModel.selectedLookBookIds.isEmpty,
                action: viewModel.handleCompleteAction
            )
            : .overflow(
                menuType: .lookbook,
                menuActions: [
                    viewModel.toggleAddDialog,
                    viewModel.handleDeleteAction
                ]
            )
        )
        .zIndex(10)
        .padding(.leading, 15)
    }

    // MARK: - Content Area

    /// 룩북 목록 / 빈 상태 분기 처리
    private var contentArea: some View {
        Group {
            if viewModel.lookBookList.isEmpty,
               !viewModel.isLoading,
               viewModel.errorMessage == nil {
                EmptyLookBookView()
            } else {
                LookBookContent(viewModel: viewModel)
            }
        }
    }

    // MARK: - Add LookBook Dialog Overlay

    /// 룩북 추가 다이얼로그 오버레이
    @ViewBuilder
    private var addLookBookDialogOverlay: some View {
        if viewModel.isShowingAddDialog {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            LookBookDialog(
                title: TextLiteral.LookBook.addLookBookTitle,
                hintText: TextLiteral.LookBook.hintAddLookBookTitle,
                buttonText: TextLiteral.Common.complete,
                action: { text in
                    viewModel.handleAddLookBook(title: text)
                },
                dismissAction: {
                    viewModel.handleDialogCancelTap()
                }
            )
        }
    }
}

// MARK: - SubViews

/// 룩북 목록을 그리드 형태로 표시하는 View
private struct LookBookContent: View {

    // MARK: - Properties

    @ObservedObject var viewModel: LookBookViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView(TextLiteral.LookBook.loadingTitle)
                    .padding(.top, 100)
            } else {
                gridContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Grid Content

    private var gridContent: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 16),
                count: 2
            ),
            spacing: 16
        ) {
            ForEach(viewModel.lookBookList) { lookbook in
                LookBookCard(
                    imageURL: lookbook.imageURL,
                    cardTitle: lookbook.cardTitle,
                    iconType: viewModel.isEditing ? .checkmark : .none,
                    isSelected: viewModel.selectedLookBookIds.contains(lookbook.id)
                )
                .onTapGesture {
                    if viewModel.isEditing {
                        viewModel.toggleSelection(id: lookbook.id)
                    } else {
                        viewModel.navigateToSpecificLookBook(id: lookbook.id)
                    }
                }
            }
        }
        .padding([.horizontal, .top], 16)
    }
}

/// 룩북이 하나도 없을 때 표시되는 빈 상태 View
private struct EmptyLookBookView: View {

    var body: some View {
        Color.white
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
