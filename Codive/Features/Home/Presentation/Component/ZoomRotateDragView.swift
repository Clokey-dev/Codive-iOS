//
//  ZoomRotateDragView.swift
//  PinchGesture
//
//  Created by 한금준 on 1/19/26.
//

import SwiftUI

// MARK: - Zoom + Rotate + Drag 가능한 공용 View
struct ZoomRotateDragView<Content: View>: View {

    let id: UUID
    @Binding var activeID: UUID?
    let onActivate: () -> Void
    let content: Content

    // Scale
    @State private var scale: CGFloat = 1.0
    @GestureState private var magnification: CGFloat = 1.0

    // Rotation
    @State private var angle: Angle = .zero

    // Position
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    init(
        id: UUID,
        activeID: Binding<UUID?>,
        onActivate: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self._activeID = activeID
        self.onActivate = onActivate
        self.content = content()
    }

    var body: some View {
        content
            .scaleEffect(scale * magnification)
            .rotationEffect(angle)
            .offset(
                x: offset.width + dragOffset.width,
                y: offset.height + dragOffset.height
            )
            .highPriorityGesture(
                (activeID == nil || activeID == id)
                ? combinedGesture
                : nil
            )
    }

    // MARK: - Gesture
    private var combinedGesture: some Gesture {
        SimultaneousGesture(
            SimultaneousGesture(
                // Pinch
                magnificationGesture,

                // Rotation
                RotationGesture()
                    .onChanged { value in
                        activate()
                        angle = value
                    }
                    .onEnded { _ in
                        activeID = nil
                    }
            ),

            // Drag
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                    activate()
                }
                .onEnded { value in
                    offset.width += value.translation.width
                    offset.height += value.translation.height
                    activeID = nil
                }
        )
    }

    // MARK: - Magnification (iOS 16 & 17 compatible)
    private var magnificationGesture: some Gesture {
        if #available(iOS 17.0, *) {
            return AnyGesture(
                MagnifyGesture()
                    .updating($magnification) { value, state, _ in
                        state = value.magnification
                    }
                    .onChanged { _ in
                        activate()
                    }
                    .onEnded { value in
                        scale *= value.magnification
                        activeID = nil
                    }
            )
        } else {
            return AnyGesture(
                MagnificationGesture()
                    .updating($magnification) { value, state, _ in
                        state = value
                    }
                    .onChanged { _ in
                        activate()
                    }
                    .onEnded { value in
                        scale *= value
                        activeID = nil
                    }
            )
        }
    }

    private func activate() {
        if activeID != id {
            activeID = id
            onActivate()
        }
    }
}
