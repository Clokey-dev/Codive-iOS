//
//  EditCodiView.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

struct EditCodiView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: EditCodiViewModel
    
    // MARK: - Initializer
    
    init(viewModel: EditCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView {
                VStack(spacing: 24) {
                    imagePreviewArea
                    inputSection
                }
                .padding(20)
            }
            
            completeButton
        }
        .navigationBarHidden(true)
        .background(Color.white)
    }
}

// MARK: - View Components

private extension EditCodiView {
    
    /// 변경 사항 여부에 따른 커스텀 네비게이션 바
    var navigationBar: some View {
        CustomNavigationBar(
            title: $viewModel.codiName, // String이 아닌 Binding<String> 전달
            isEditingMode: viewModel.isNavEditingMode,
            onBack: { viewModel.handleBackTap() },
            onBeginEditTitle: {
                viewModel.startNavEditing()
            },
            onConfirmEditTitle: {
                viewModel.finishNavEditing()
            },
            rightButton: viewModel.hasChanges ? .text(
                title: TextLiteral.Common.complete,
                isEnabled: viewModel.isButtonEnabled,
                action: viewModel.handleCompleteTap
            ) : .none
        )
        .padding(.leading, 15)
    }

    var imagePreviewArea: some View {
        Group {
            if let url = viewModel.selectedImageURL {
                ZStack {
                    AsyncImage(url: URL(string: url)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.1))
                        }
                    }
                    .frame(height: 335)
                    .id(url) // URL이 바뀔 때 뷰를 강제로 새로 그리도록 명시적 ID 부여 가능
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    EditCodiOverlayView()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle()) // 투명한 부분도 탭 가능하게
                        .onTapGesture {
                            viewModel.handleOverlayTap()
                        }
                }
            }
        }
        .frame(height: 335)
    }
    
    /// 코디 이름 및 메모 입력 섹션
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
    
    /// 하단 수정 완료 버튼
    var completeButton: some View {
        CustomButton(
            text: TextLiteral.LookBook.editCodiComplete,
            widthType: .fixed,
            isEnabled: viewModel.isButtonEnabled
        ) {
            viewModel.handleCompleteTap()
        }
        .padding(20)
    }
}
