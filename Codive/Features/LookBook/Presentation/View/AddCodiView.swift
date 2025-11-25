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
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                title: TextLiteral.LookBook.addCodiTitle
            ) {
                viewModel.handleBackTap()
            }
            
            ScrollView {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 335)
                        
                        CustomButton(text: TextLiteral.LookBook.codiUpload, widthType: .dynamic) {}
                    }
                    
                    CustomTextField1(
                        title: TextLiteral.LookBook.codiNameTitle,
                        placeholder: TextLiteral.LookBook.hintCodiNameTitle,
                        text: $viewModel.codiName,
                        showRequiredMark: true
                    )
                    .padding(.top, 24)
                    
                    CustomTextField1(
                        title: TextLiteral.LookBook.memoTitle,
                        placeholder: TextLiteral.LookBook.hintMemo,
                        text: $viewModel.memo
                    )
                    .padding(.top, 12)
                }
            }
            .padding(.horizontal, 20)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 9) {
                    CustomButton(
                        text: TextLiteral.LookBook.addCodiCompleteButton,
                        widthType: .fixed,
                        isEnabled: viewModel.isButtonEnabled
                    ) {
                        viewModel.handleCompleteTap()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(alignment: .center) {
                    Color.white
                }
            }
        }
    }
}

#Preview {
    AddCodiView(viewModel: AddCodiViewModel.preview)
}
