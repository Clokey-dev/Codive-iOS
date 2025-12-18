//
//  EditCodiView.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

struct EditCodiView: View {
    @StateObject private var viewModel: EditCodiViewModel
    
    init(viewModel: EditCodiViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 조건부 네비게이션 바
            if viewModel.hasChanges {
                // 수정 사항이 있는 경우
                CustomNavigationBar(
                    title: "새 코디 만들기",
                    onBack: { viewModel.handleBackTap() },
                    rightButton: .text(
                        title: "완료",
                        isEnabled: viewModel.isButtonEnabled,
                        action: viewModel.handleCompleteTap
                    )
                )
                .padding(.leading, 15)
            } else {
                // 수정 사항이 없는 경우
                CustomNavigationBar(
                    title: "이전 코디",
                    onBack: { viewModel.handleBackTap() }
                )
                .padding(.leading, 15)
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // 이미지 및 애니메이션 영역
                    ZStack {
                        if let url = viewModel.selectedImageURL {
                            AsyncImage(url: URL(string: url)) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(height: 335)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // 애니메이션 오버레이
                            EditCodiOverlayView()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .frame(height: 335)
                    
                    VStack(spacing: 12) {
                        CustomTextField1(
                            title: "코디 명",
                            placeholder: "코디 명을 입력해주세요",
                            text: $viewModel.codiName,
                            showRequiredMark: true
                        )
                        
                        CustomTextField1(
                            title: "개인 메모",
                            placeholder: "메모를 입력해주세요",
                            text: $viewModel.memo
                        )
                    }
                }
                .padding(20)
            }
            
            // 하단 버튼 (수정 사항이 있을 때만 활성화 권장)
            CustomButton(
                text: "수정 완료하기", widthType: .fixed,
                isEnabled: viewModel.isButtonEnabled
            ) {
                viewModel.handleCompleteTap()
            }
            .padding(20)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    AddCodiView(viewModel: AddCodiViewModel.preview)
}
