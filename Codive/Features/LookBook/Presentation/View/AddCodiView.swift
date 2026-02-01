//
//  AddCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI

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
    
    /// 전체적인 메인 레이아웃
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
    
    /// 상단 네비게이션 바
    var navigationBar: some View {
        CustomNavigationBar(
            title: TextLiteral.LookBook.addCodiTitle,
            onBack: viewModel.handleBackTap
        )
        .padding(.leading, 15)
    }
    
    /// 코디 이미지 미리보기 영역 (상태에 따라 3가지 뷰 전환)
    var codiPreviewArea: some View {
        ZStack {
            if !viewModel.combinedItems.isEmpty {
                combinedCodiBoard
            } else if let imageURL = viewModel.selectedImageURL, !imageURL.isEmpty {
                selectedImagePreview(url: imageURL)
            } else {
                emptyUploadPlaceholder
            }
        }
        .frame(height: 335)
    }
    
    /// 정보 입력 섹션 (코디 이름, 메모)
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
    
    /// 하단 완료 버튼
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
    
    /// 조합된 코디판 뷰
    var combinedCodiBoard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemGray6))
            
            ForEach(viewModel.combinedItems) { item in
                AsyncImage(url: URL(string: item.name)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    }
                }
                .frame(width: 80, height: 80)
                .scaleEffect(item.scale)
                .rotationEffect(.degrees(item.rotation))
                .position(x: item.position.x, y: item.position.y)
            }
            
            EditCodiOverlayView()
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    /// 단일 선택 이미지 미리보기 뷰
    func selectedImagePreview(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 335)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            case .failure:
                Image(systemName: "photo").foregroundColor(.gray)
            case .empty:
                ProgressView()
            @unknown default:
                EmptyView()
            }
        }
    }
    
    /// 업로드 전 빈 상태의 플레이스홀더
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
    
    /// 바텀시트 오버레이
    var bottomSheetOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    viewModel.isShowingBottomSheet = false
                }
            
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
    
    /// 등록 성공 메시지 뷰
    var successOverlay: some View {
        CustomSuccessView(message: viewModel.successMessage)
            .transition(.opacity)
            .zIndex(1000)
    }
}
