//
//  CodiBoardView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct CodiBoardView: View {
    @StateObject private var viewModel: CodiBoardViewModel
    
    init(viewModel: CodiBoardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            /// 네비게이션 바
            CustomNavigationBar(
                title: "코디 보드"
            ) {
                viewModel.handleBackTap()
            }
            
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Text("옷을 자유롭게 배치해 스타일을 살펴보세요.")
                            .font(Font.codive_title2)
                            .foregroundStyle(Color.Codive.grayscale1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
                        
                        /// 코디 보드 공간
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.Codive.grayscale7)
                            .frame(
                                width: geometry.size.width - 40,
                                height: geometry.size.width - 40
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.Codive.grayscale5, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                    .frame(width: geometry.size.width)
                }
                .safeAreaInset(edge: .bottom) {
                    CustomButton(
                        text: "이 코디로 결정하기",
                        widthType: .fixed,
                        action: viewModel.handleConfirmCodi
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .onChange(of: viewModel.isConfirmed) { confirmed in
            if confirmed {
                print("코디 확정 완료!")
            }
        }
    }
}
