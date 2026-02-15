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
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isOverflowMenuExpanded {
                        viewModel.closeOverflowMenu()
                    }
                }
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
    
    private var mainLayout: some View {
        VStack(spacing: 0) {
            topBar
            contentArea
        }
    }
    
    private var topBar: some View {
        CustomNavigationBar(
            title: TextLiteral.LookBook.title,
            onBack: viewModel.handleBackTap,
            rightButton: viewModel.isEditing
            ? .text(
                title: TextLiteral.Common.delete,
                isEnabled: viewModel.selectedLookBookId != nil,
                action: viewModel.handleCompleteAction
            )
            : .overflow(
                menuType: .lookbook,
                menuActions: [
                    viewModel.toggleAddDialog,
                    viewModel.handleDeleteAction
                ],
                isExpanded: viewModel.isOverflowMenuExpanded,
                onToggle: viewModel.toggleOverflowMenu,
                onClose: viewModel.closeOverflowMenu
            )
        )
        .zIndex(10)
        .padding(.leading, 15)
    }
    
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
                    count: Int(lookbook.count),
                    imageUrl: lookbook.imageUrl,
                    mode: viewModel.isEditing
                    ? .check(isSelected: viewModel.selectedLookBookId == lookbook.id)
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

private struct EmptyLookBookView: View {
    
    var body: some View {
        Color.white
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
