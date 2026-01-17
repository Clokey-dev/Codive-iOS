//
//  DraggableImageView.swift
//  Codive
//
//  Created by 한금준 on 11/11/25.
//

import SwiftUI

@MainActor
protocol DraggableImageViewModelProtocol: ObservableObject {
    var images: [DraggableImageEntity] { get set }
    var currentlyDraggedID: Int? { get set }
    var selectedImageID: Int? { get set }
    
    func bringImageToFront(id: Int)
    func updateImagePosition(id: Int, newPosition: CGPoint)
    func updateImageScale(id: Int, newScale: CGFloat)
    func updateImageRotation(id: Int, newRotation: Double)
    func selectImage(id: Int?)
}

extension DraggableImageViewModelProtocol {
    func selectImage(id: Int?) {
        // 기본 구현
    }
}

struct DraggableImageView<ViewModel: DraggableImageViewModelProtocol>: View {
    @Binding var image: DraggableImageEntity
    let imageHalfSize: CGFloat
    let minBound: CGFloat
    let maxBound: CGFloat
    @ObservedObject var viewModel: ViewModel
    
    // 흔들림 방지를 위한 드래그 시작 시점의 위치 저장
    @State private var dragStartPosition: CGPoint = .zero
    
    private let borderWidth: CGFloat = 3
    private let gestureAreaMultiplier: CGFloat = 2.0
    
    private var isSelected: Bool {
        viewModel.selectedImageID == image.id
    }
    
    private var isInteractionDisabled: Bool {
        if let selectedID = viewModel.selectedImageID {
            return selectedID != image.id
        }
        return false
    }
    
    var body: some View {
        ZStack {
            // 제스처 영역
            if isSelected {
                Rectangle()
                    .fill(Color.clear)
                    .frame(
                        width: (imageHalfSize * 2 + borderWidth * 2) * gestureAreaMultiplier,
                        height: (imageHalfSize * 2 + borderWidth * 2) * gestureAreaMultiplier
                    )
                    .contentShape(Rectangle())
                    .gesture(createCombinedGesture())
            }
            
            // 이미지 렌더링 영역
            Group {
                if let url = URL(string: image.name), image.name.hasPrefix("http") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: imageHalfSize * 2, height: imageHalfSize * 2)
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .failure:
                            Image(systemName: "photo").resizable().scaledToFit().foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(image.name).resizable().scaledToFit()
                }
            }
            .frame(width: imageHalfSize * 2, height: imageHalfSize * 2)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.5), lineWidth: borderWidth)
            )
            .rotationEffect(.degrees(image.rotationAngle))
            .scaleEffect(image.scale)
        }
        .position(image.position)
        .allowsHitTesting(!isInteractionDisabled)
        .onTapGesture {
            if !isInteractionDisabled {
                viewModel.selectImage(id: image.id)
                viewModel.bringImageToFront(id: image.id)
            }
        }
    }
    
    // MARK: - Gestures
    
    private func createCombinedGesture() -> some Gesture {
        // 현재 선택된 상태라면 즉시 드래그 가능, 아니면 롱프레스 필요
        let drag = createDragGesture()
        let magnify = createMagnificationGesture()
        let rotate = createRotationGesture()
        
        return SimultaneousGesture(
            drag,
            SimultaneousGesture(magnify, rotate)
        )
    }
    
    private func createDragGesture() -> some Gesture {
        // 핵심 수정: 이미 선택된(활성화된) 이미지라면 꾹 누르기 없이 즉시 반응
        let baseDrag = DragGesture(coordinateSpace: .global)
            .onChanged { value in
                handleDragChanged(value)
            }
            .onEnded { _ in
                viewModel.currentlyDraggedID = nil
            }
        
        if isSelected {
            // 활성화 상태: 즉시 드래그 반환
            return AnyGesture(baseDrag.map { _ in () })
        } else {
            // 비활성화 상태: 0.5초 대기 후 드래그 가능 (기존 로직 유지)
            let longPressDrag = LongPressGesture(minimumDuration: 0.5)
                .sequenced(before: DragGesture(coordinateSpace: .global))
                .onChanged { value in
                    switch value {
                    case .second(true, let drag):
                        if let dragValue = drag {
                            handleDragChanged(dragValue)
                        }
                    default:
                        break
                    }
                }
                .onEnded { _ in
                    viewModel.currentlyDraggedID = nil
                }
            return AnyGesture(longPressDrag.map { _ in () })
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        if viewModel.currentlyDraggedID == nil {
            viewModel.currentlyDraggedID = image.id
            // 드래그 시작 시점의 실제 위치 고정
            dragStartPosition = image.position
            viewModel.bringImageToFront(id: image.id)
        }
        
        if viewModel.currentlyDraggedID == image.id {
            // translation을 사용하여 누적 이동량 계산 (흔들림 방지)
            let newX = dragStartPosition.x + value.translation.width
            let newY = dragStartPosition.y + value.translation.height
            
            let clampedX = max(minBound, min(maxBound, newX))
            let clampedY = max(minBound, min(maxBound, newY))
            
            viewModel.updateImagePosition(id: image.id, newPosition: CGPoint(x: clampedX, y: clampedY))
        }
    }
    
    private func createMagnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scaleValue in
                let newScale = max(0.5, min(2.0, scaleValue))
                viewModel.updateImageScale(id: image.id, newScale: newScale)
            }
    }
    
    private func createRotationGesture() -> some Gesture {
        RotationGesture()
            .onChanged { angle in
                viewModel.updateImageRotation(id: image.id, newRotation: angle.degrees)
            }
    }
}

// MARK: - 컨테이너 뷰
struct DraggableImageContainerView<ViewModel: DraggableImageViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let imageHalfSize: CGFloat
    let minBound: CGFloat
    let maxBound: CGFloat
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.selectedImageID != nil {
                        viewModel.selectImage(id: nil)
                    }
                }
            
            ForEach(viewModel.images.indices, id: \.self) { index in
                DraggableImageView(
                    image: $viewModel.images[index],
                    imageHalfSize: imageHalfSize,
                    minBound: minBound,
                    maxBound: maxBound,
                    viewModel: viewModel
                )
            }
        }
    }
}
