//
//  EditCodiView.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

struct EditCodiView: View {
    
    // MARK: - State Object
    
    @StateObject private var viewModel: EditCodiViewModel
    
    // MARK: - Initializer
    
    init(viewModel: EditCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Conditional Navigation Bar
            
            if viewModel.hasChanges {
                
                // MARK: Navigation Bar (With Changes)
                
                CustomNavigationBar(
                    title: viewModel.codiName,
                    onBack: { viewModel.handleBackTap() },
                    rightButton: .text(
                        title: TextLiteral.Common.complete,
                        isEnabled: viewModel.isButtonEnabled,
                        action: viewModel.handleCompleteTap
                    )
                )
                .padding(.leading, 15)
            } else {
                
                // MARK: Navigation Bar (No Changes)
                
                CustomNavigationBar(
                    title: viewModel.codiName
                ) {
                    viewModel.handleBackTap()
                }
                .padding(.leading, 15)
            }
            
            // MARK: - Scrollable Content
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: Image Preview Area
                    
                    ZStack {
                        if let url = viewModel.selectedImageURL {
                            AsyncImage(url: URL(string: url)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Color.gray.opacity(0.2)
                                }
                            }
                            .frame(height: 335)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // MARK: Animation Overlay
                            
                            EditCodiOverlayView()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .frame(height: 335)
                    
                    // MARK: Codi Information Input
                    
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
                .padding(20)
            }
            
            // MARK: - Bottom Action Button
            
            CustomButton(
                text: TextLiteral.LookBook.editCodiComplete,
                widthType: .fixed,
                isEnabled: viewModel.isButtonEnabled
            ) {
                viewModel.handleCompleteTap()
            }
            .padding(20)
        }
        .navigationBarHidden(true)
        .background(Color.white)
    }
}
