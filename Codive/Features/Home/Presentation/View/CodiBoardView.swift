//
//  CodiBoardView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct CodiBoardView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: CodiBoardViewModel
    
    // MARK: - Initialization
    init(viewModel: CodiBoardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            GeometryReader { geometry in
                let boardSize = geometry.size.width - 40
                let imageHalfSize: CGFloat = 40
                
                contentView(boardSize: boardSize, imageHalfSize: imageHalfSize, totalWidth: geometry.size.width)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .onChange(of: viewModel.isConfirmed) { confirmed in
            if confirmed {
                // 확인 로직 처리
            }
        }
    }
}

// MARK: - View Components
private extension CodiBoardView {
    
    /// 상단 커스텀 네비게이션 바
    var navigationBar: some View {
        CustomNavigationBar(title: TextLiteral.Home.codiBoardTitle) {
            viewModel.handleBackTap()
        }
    }
    
    /// 메인 컨텐츠 영역 (설명 + 보드)
    func contentView(boardSize: CGFloat, imageHalfSize: CGFloat, totalWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            descriptionText

            drawingBoard(size: boardSize, imageHalfSize: imageHalfSize)

            Spacer()
        }
        .frame(
            maxWidth: totalWidth,
            maxHeight: .infinity
        )        .safeAreaInset(edge: .bottom) {
            confirmationButton
        }
    }
    
    /// 상단 설명 텍스트
    var descriptionText: some View {
        Text(TextLiteral.Home.codiBoardDescription)
            .font(.codive_title2)
            .foregroundStyle(Color.Codive.grayscale1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
    }
    
    /// 이미지들을 배치하고 드래그할 수 있는 보드 영역
    // CodiBoardView.swift

    func drawingBoard(size: CGFloat, imageHalfSize: CGFloat) -> some View {
        ZStack {
            boardBackground(size: size) // 260x260 영역
            
            // DraggableImageView의 각 아이템들은 ZStack의 중앙(0,0)을 기준으로
            // 위에서 넘겨준 relativePos 만큼 offset 되어 배치됩니다.
            DraggableImageView(
                items: $viewModel.images,
                onActivate: { id in
                    viewModel.selectImage(id: Int(id))
                    viewModel.bringImageToFront(id: Int(id))
                }
            )
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 15)) // 보드 밖으로 나가는 이미지 절단
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    /// 보드의 배경 디자인
    func boardBackground(size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.Codive.grayscale7)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.Codive.grayscale5, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
    
    /// 하단 확정 버튼
    var confirmationButton: some View {
        CustomButton(
            text: TextLiteral.Home.complete,
            widthType: .fixed,
            action: viewModel.handleConfirmCodi
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }
}
