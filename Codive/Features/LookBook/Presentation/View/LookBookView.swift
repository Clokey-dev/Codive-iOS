//
//  LookBookView.swift
//
//  Created by 한금준 on 11/27/25.
//  Codive
//

import SwiftUI

struct LookBookView: View {
    
    // MARK: - State & Dependencies
    
    @StateObject private var viewModel: LookBookViewModel
    
    // MARK: - Initializer
    
    init(viewModel: LookBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            mainLayout
            addLookBookDialogOverlay
            
            if viewModel.isLoading {
                LoadingView(backgroundStyle: .white)
            }
        }
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
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    // MARK: - Main Layout
    
    private var mainLayout: some View {
        VStack(spacing: 0) {
            topBar
            contentArea
        }
    }
    
    // MARK: - Top Navigation Bar
    
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
                    LookBookFolder(
                        title: lookbook.lookbookName,
                        count: lookbook.count,
                        thumbnail: AsyncImage(url: URL(string: lookbook.imageUrl)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.Codive.grayscale6
                        },
                        mode: viewModel.isEditing
                            ? .check(isSelected: viewModel.selectedLookBookIds.contains(lookbook.id))
                            : .none
                    ) {
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
