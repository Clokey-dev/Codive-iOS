//
//  AddCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI
import Kingfisher

struct AddCodiView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: AddCodiViewModel
    
    // MARK: - Initializer
    init(viewModel: AddCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            mainContent
                .disabled(viewModel.isShowingBottomSheet)
            
            if viewModel.isShowingBottomSheet {
                bottomSheetOverlay
            }
            
            if viewModel.isShowingSuccessView {
                successOverlay
            }
        }
        .navigationBarHidden(true)
        .enableSwipeBack()
        .background(Color.white)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isShowingSuccessView)
    }
}

// MARK: - View Components
private extension AddCodiView {
    
    var mainContent: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView {
                VStack(spacing: 24) {
                    codiPreviewArea
                    inputSection
                }
                .padding(20)
            }
            
            completeButton
        }
    }
    
    var navigationBar: some View {
        CustomNavigationBar(
            title: TextLiteral.LookBook.addCodiTitle,
            onBack: viewModel.handleBackTap
        )
        .padding(.leading, 15)
    }
    
    var codiPreviewArea: some View {
        GeometryReader { geometry in
            ZStack {
                if let capturedImage = viewModel.capturedImage {
                    selectedImagePreview(image: capturedImage)
                } else if let imageURL = viewModel.selectedImageURL, !imageURL.isEmpty {
                    selectedImagePreview(url: imageURL)
                } else {
                    emptyUploadPlaceholder
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    var inputSection: some View {
        VStack(spacing: 12) {
            CustomTextField1(
                title: TextLiteral.LookBook.codiNameTitle,
                placeholder: TextLiteral.LookBook.hintCodiNameTitle,
                text: $viewModel.codiName,
                showRequiredMark: true
            )
            
            CustomTextField1(
                title: TextLiteral.LookBook.memoTitle,
                placeholder: TextLiteral.LookBook.hintMemo,
                text: $viewModel.memo
            )
        }
    }
    
    var completeButton: some View {
        CustomButton(
            text: TextLiteral.LookBook.addCodiCompleteButton,
            widthType: .fixed,
            isEnabled: viewModel.isButtonEnabled
        ) {
            viewModel.handleCompleteTap()
        }
        .padding(20)
    }
}

private extension AddCodiView {
    func selectedImagePreview(image: UIImage) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
            
            EditCodiOverlayView()
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    func selectedImagePreview(url: String) -> some View {
        ZStack {
            KFImage(URL(string: url))
                .placeholder {
                    Image(systemName: "photo")
                        .foregroundStyle(.gray)
                }
                .onFailure { _ in }
                .resizable()
                .scaledToFill()
            
            if !viewModel.isPastCodiSelected {
                EditCodiOverlayView()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.handleEditCodiTap()
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var emptyUploadPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.1))
            .overlay {
                CustomButton(
                    text: TextLiteral.LookBook.codiUpload,
                    widthType: .dynamic
                ) {
                    viewModel.handleCodiUploadTap()
                }
                .fixedSize()
            }
    }
}

private extension AddCodiView {
    var bottomSheetOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { viewModel.isShowingBottomSheet = false }
            
            VStack {
                Spacer()
                CustomBottomSheet(
                    iconName1: "plus",
                    iconName2: "clo_selected",
                    title1: TextLiteral.LookBook.addNewCodi,
                    title2: TextLiteral.LookBook.getBeforeCodi,
                    action1: { viewModel.navigateToNewCodi() },
                    action2: { viewModel.handleRecallCodi() }
                )
            }
        }
    }
    
    var successOverlay: some View {
        CustomSuccessView(message: viewModel.successMessage)
            .transition(.opacity)
            .zIndex(1000)
    }
}
