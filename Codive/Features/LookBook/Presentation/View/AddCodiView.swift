//
//  AddCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI

struct AddCodiView: View {
    @StateObject private var viewModel: AddCodiViewModel
    
    init(viewModel: AddCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: TextLiteral.LookBook.addCodiTitle,
                    onBack: viewModel.handleBackTap
                )
                .padding(.leading, 15)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 코디 이미지 영역 (기존 로직 유지)
                        ZStack {
                            if !viewModel.combinedItems.isEmpty {
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
                                        .rotationEffect(.degrees(item.rotationAngle))
                                        .position(x: item.position.x, y: item.position.y)
                                    }
                                    
                                    EditCodiOverlayView()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            } else if let imageURL = viewModel.selectedImageURL, !imageURL.isEmpty {
                                AsyncImage(url: URL(string: imageURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
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
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 335)
                                    .overlay {
                                        CustomButton(text: TextLiteral.LookBook.codiUpload, widthType: .dynamic) {
                                            viewModel.handleCodiUploadTap()
                                        }
                                    }
                            }
                        }
                        .frame(height: 335)
                        
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
                
                // 하단 버튼
                CustomButton(
                    text: TextLiteral.LookBook.addCodiCompleteButton,
                    widthType: .fixed,
                    isEnabled: viewModel.isButtonEnabled
                ) {
                    viewModel.handleCompleteTap()
                }
                .padding(20)
            }
            .disabled(viewModel.isShowingBottomSheet)
            
            if viewModel.isShowingBottomSheet {
                bottomSheetOverlay
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        // ✅ 성공 화면 풀스크린 커버 추가
        .fullScreenCover(isPresented: $viewModel.isShowingSuccessView) {
            CustomSuccessView(message: viewModel.successMessage)
        }
    }
    
    private var bottomSheetOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
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
}

#Preview {
    AddCodiView(viewModel: AddCodiViewModel.preview)
}
