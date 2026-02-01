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
    
    /// 코디 이미지 미리보기 영역 (상태에 따라 전환)
    var codiPreviewArea: some View {
        ZStack {
            if let capturedImage = viewModel.capturedImage {
                // 1. 상세 화면에서 캡처해서 돌아온 경우
                selectedImagePreview(image: capturedImage)
            } else if let imageURL = viewModel.selectedImageURL, !imageURL.isEmpty {
                // 2. 단일 이미지를 선택한 경우 (서버 URL)
                selectedImagePreview(url: imageURL)
            } else {
                // 3. 아무것도 없는 초기 상태
                emptyUploadPlaceholder
            }
        }
        .frame(height: 335)
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

// MARK: - Subviews (Preview Variations)
private extension AddCodiView {
    
    /// 캡처된 UIImage용 미리보기
    func selectedImagePreview(image: UIImage) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
            
            EditCodiOverlayView()
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: 335)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 서버 URL용 미리보기 (Kingfisher 활용)
    func selectedImagePreview(url: String) -> some View {
        ZStack {
            KFImage(URL(string: url))
                .placeholder { ProgressView() }
                .onFailure { _ in Image(systemName: "photo").foregroundColor(.gray) }
                .resizable()
                .scaledToFill()
            
//            EditCodiOverlayView()
//                .clipShape(RoundedRectangle(cornerRadius: 12))
            EditCodiOverlayView()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle()) // 전체 영역을 탭 가능하게
                .onTapGesture {
                    viewModel.handleEditCodiTap()
                }
        }
        .frame(height: 335)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 초기 상태의 플레이스홀더 (요청하신 코드 적용)
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
            }
    }
}

// MARK: - Overlays
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
