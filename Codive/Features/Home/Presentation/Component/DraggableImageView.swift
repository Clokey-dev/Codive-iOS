//
//  DraggableImageView.swift
//  Codive
//
//  Created by 한금준 on 11/11/25.
//

import SwiftUI

struct DraggableImageView: View {
    @Binding var image: DraggableImageEntity
    let imageHalfSize: CGFloat
    let minBound: CGFloat
    let maxBound: CGFloat
    @ObservedObject var viewModel: CodiBoardViewModel
    
    var body: some View {
        Image(image.name)
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(image.rotationAngle))
            .scaleEffect(image.scale)
            .frame(width: imageHalfSize * 2, height: imageHalfSize * 2)
            .position(image.position)
            .gesture(createCombinedGesture())
            .onTapGesture {
                viewModel.bringImageToFront(id: image.id)
            }
    }
    
    private func createCombinedGesture() -> some Gesture {
        let drag = createDragGesture()
        let magnify = createMagnificationGesture()
        let rotate = createRotationGesture()
        
        return SimultaneousGesture(
            drag,
            SimultaneousGesture(magnify, rotate)
        )
    }
    
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                handleDragChanged(value)
            }
            .onEnded { _ in
                viewModel.currentlyDraggedID = nil
            }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        if viewModel.currentlyDraggedID == nil {
            viewModel.currentlyDraggedID = image.id
            viewModel.bringImageToFront(id: image.id)
        }
        
        if let activeId = viewModel.currentlyDraggedID {
            let clampedX = max(minBound, min(maxBound, value.location.x))
            let clampedY = max(minBound, min(maxBound, value.location.y))
            let newPosition = CGPoint(x: clampedX, y: clampedY)
            viewModel.updateImagePosition(id: activeId, newPosition: newPosition)
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
