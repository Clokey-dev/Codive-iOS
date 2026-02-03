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

private extension EditCodiView {
    var navigationBar: some View {
        CustomNavigationBar(
            title: $viewModel.codiName,
            isEditingMode: viewModel.isNavEditingMode,
            onBack: { viewModel.handleBackTap() },
            onBeginEditTitle: {
                viewModel.startNavEditing()
            },
            onConfirmEditTitle: {
                viewModel.finishNavEditing()
            }
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
                    .id(url)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    EditCodiOverlayView()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.handleOverlayTap()
                        }
                }
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
            text: TextLiteral.LookBook.editCodiComplete,
            widthType: .fixed,
            isEnabled: viewModel.isButtonEnabled
        ) {
            viewModel.handleCompleteTap()
        }
        .padding(20)
    }
}
