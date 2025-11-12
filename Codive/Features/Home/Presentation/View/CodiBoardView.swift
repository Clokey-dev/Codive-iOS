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
            CustomNavigationBar(title: TextLiteral.Home.codiBoardTitle) {
                viewModel.handleBackTap()
            }

            GeometryReader { geometry in
                let boardSize = geometry.size.width - 40
                let imageHalfSize: CGFloat = 40
                let minBound = imageHalfSize
                let maxBound = boardSize - imageHalfSize

                ScrollView {
                    VStack {
                        Text(TextLiteral.Home.codiBoardDescription)
                            .font(Font.codive_title2)
                            .foregroundStyle(Color.Codive.grayscale1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)

                        ZStack {
                            boardBackground(size: boardSize)
                            
                            ForEach($viewModel.images) { $image in
                                DraggableImageView(
                                    image: $image,
                                    imageHalfSize: imageHalfSize,
                                    minBound: minBound,
                                    maxBound: maxBound,
                                    viewModel: viewModel
                                )
                            }
                        }
                        .frame(width: boardSize, height: boardSize)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(width: geometry.size.width)
                }
                .safeAreaInset(edge: .bottom) {
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
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .onChange(of: viewModel.isConfirmed) { confirmed in
            if confirmed { }
        }
    }
    
    @ViewBuilder
    private func boardBackground(size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.Codive.grayscale7)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.Codive.grayscale5, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}
