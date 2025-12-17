// LookBookView.swift

import SwiftUI

struct LookBookView: View {
    @StateObject private var viewModel: LookBookViewModel
    @ObservedObject private var navigationRouter: NavigationRouter
    private let lookBookDIContainer: LookBookDIContainer
    
    init(viewModel: LookBookViewModel, lookBookDIContainer: LookBookDIContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.navigationRouter = viewModel.navigationRouter
        self.lookBookDIContainer = lookBookDIContainer
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            ZStack {
                VStack(spacing: 0) {
                    CustomNavigationBar(
                        title: TextLiteral.LookBook.title,
                        onBack: viewModel.handleBackTap,
                        rightButton: viewModel.isEditing ?
                            .text(title: TextLiteral.Common.delete, isEnabled: !viewModel.selectedLookBookIds.isEmpty, action: viewModel.handleCompleteAction) :
                            .overflow(menuType: .lookbook, menuActions: [viewModel.toggleAddDialog, viewModel.handleDeleteAction])
                    )
                    .zIndex(10)
                    .padding(.leading, 15)
                    
                    if viewModel.lookBookList.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                        EmptyLookBookView()
                    } else {
                        LookBookContent(viewModel: viewModel)
                    }
                }
                .navigationDestination(for: AppDestination.self) { destination in
                    lookBookDIContainer.lookBookViewFactory.makeView(for: destination)
                }
                .navigationBarHidden(true)
                .background(Color.white)
                
                // 얼럿들
                .alert(TextLiteral.LookBook.alertDeleteTitle, isPresented: $viewModel.isShowingDeleteAlert) {
                    Button(TextLiteral.Common.delete, role: .destructive) { viewModel.confirmDelete() }
                    Button(TextLiteral.Common.cancel, role: .cancel) { }
                } message: {
                    Text(TextLiteral.LookBook.alertDeleteSubTitle)
                }
                
                .alert("정말 나가시겠습니까?", isPresented: $viewModel.isShowingCancelConfirmAlert) {
                    Button("나가기", role: .destructive) { viewModel.confirmCancelDialog() }
                    Button("취소", role: .cancel) { }
                } message: {
                    Text("작성중인 내용은 복구할 수 없습니다")
                }
                
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
            .onAppear {
                if viewModel.lookBookList.isEmpty && !viewModel.isLoading {
                    viewModel.fetchLookBooks()
                }
            }
        }
    }
}

// SubViews (LookBookContent, EmptyLookBookView는 기존 코드 유지)
private struct LookBookContent: View {
    @ObservedObject var viewModel: LookBookViewModel
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView(TextLiteral.LookBook.loadingTitle).padding(.top, 100)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct EmptyLookBookView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled").font(.system(size: 60)).foregroundStyle(.gray)
            Text("아직 룩북이 없습니다").font(.headline).foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
