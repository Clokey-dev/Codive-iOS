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
                            
                            // 선택된 이미지가 있으면 표시
                            if let imageURL = viewModel.selectedImageURL {
                                AsyncImage(url: URL(string: imageURL)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 335)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    case .failure:
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                CustomButton(text: TextLiteral.LookBook.codiUpload, widthType: .dynamic) {
                                    viewModel.handleCodiUploadTap()
                                }
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
                        title1: TextLiteral.LookBook.addNewCodi,
                        title2: TextLiteral.LookBook.getBeforeCodi,
                        action1: { viewModel.navigateToNewCodi() },
                        action2: { viewModel.handleRecallCodi() }
                    )
                    .padding(.bottom, 0)
                }
                .edgesIgnoringSafeArea(.bottom)
                .transition(.move(edge: .bottom))
                .animation(.easeOut(duration: 0.8), value: viewModel.isShowingBottomSheet)
            }
        }
        .navigationBarHidden(true)
        .background(alignment: .center) {
            Color.white
        }
    }
}

#Preview {
    AddCodiView(viewModel: AddCodiViewModel.preview)
}
