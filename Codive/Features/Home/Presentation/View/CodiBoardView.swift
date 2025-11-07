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
            CustomNavigationBar(title: "코디 보드") {
                viewModel.handleBackTap()
            }

            GeometryReader { geometry in
                let boardSize = geometry.size.width - 40
                let imageHalfSize: CGFloat = 40
                let minBound = imageHalfSize
                let maxBound = boardSize - imageHalfSize

                ScrollView {
                    VStack {
                        Text("옷을 자유롭게 배치하고 확대/축소할 수 있어요.")
                            .font(Font.codive_title2)
                            .foregroundStyle(Color.Codive.grayscale1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)

                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.Codive.grayscale7)
                                .frame(width: boardSize, height: boardSize)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.Codive.grayscale5, lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)

                            ForEach($viewModel.images) { $image in
                                Image(image.name)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(image.scale) // 확대/축소 적용
                                    .frame(width: imageHalfSize * 2, height: imageHalfSize * 2)
                                    .position(image.position)
                                    .gesture(
                                        SimultaneousGesture( // Drag + Pinch 동시 처리
                                            DragGesture()
                                                .onChanged { value in
                                                    if viewModel.currentlyDraggedID == nil {
                                                        viewModel.currentlyDraggedID = image.id
                                                        viewModel.bringImageToFront(id: image.id)
                                                    }
                                                    if let activeId = viewModel.currentlyDraggedID {
                                                        let clampedX = max(minBound, min(maxBound, value.location.x))
                                                        let clampedY = max(minBound, min(maxBound, value.location.y))
                                                        viewModel.updateImagePosition(
                                                            id: activeId,
                                                            newPosition: CGPoint(x: clampedX, y: clampedY)
                                                        )
                                                    }
                                                }
                                                .onEnded { _ in
                                                    viewModel.currentlyDraggedID = nil
                                                },
                                            MagnificationGesture()
                                                .onChanged { scaleValue in
                                                    let newScale = max(0.5, min(2.0, scaleValue))
                                                    viewModel.updateImageScale(id: image.id, newScale: newScale)
                                                }
                                        )
                                    )
                                    .onTapGesture {
                                        viewModel.bringImageToFront(id: image.id)
                                    }
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
                        text: "코디 완성하기",
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
                print("코디 완성 완료, 데이터 전달됨!")
            }
        }
    }
}
