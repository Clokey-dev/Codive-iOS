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
        ZStack {
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
     
                            CustomButton(text: TextLiteral.LookBook.codiUpload, widthType: .dynamic) {
                                viewModel.handleCodiUploadTap()
                            }
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
            .disabled(viewModel.isShowingBottomSheet)
            
            if viewModel.isShowingBottomSheet {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        viewModel.isShowingBottomSheet = false
                    }

                VStack {
                    Spacer()
                    CustomBottomSheet(
                        iconName1: "addCodi",
                        iconName2: "recallCodi",
                        title1: "새로운 코디 추가하기",
                        title2: "이전 코디 불러오기"
                    )
                    .padding(.bottom, 0)
                }
                .edgesIgnoringSafeArea(.bottom)
                .transition(.move(edge: .bottom))
                .animation(.easeOut(duration: 0.8), value: viewModel.isShowingBottomSheet)
            }
        }
    }
}

#Preview {
    AddCodiView(viewModel: AddCodiViewModel.preview)
}
