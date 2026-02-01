//
//  ZoomRotateDragView.swift
//  PinchGesture
//
//  Created by 한금준 on 1/19/26.
//

import SwiftUI

struct ZoomRotateDragView<Content: View>: View {
    let id: Int
    @Binding var position: CGPoint
    @Binding var scale: CGFloat
    @Binding var rotation: Double
    
    let onActivate: () -> Void
    let content: Content

    @GestureState private var gestureOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureRotation: Angle = .zero
    
    // MARK: - 제약 조건 설정
    private let minScale: CGFloat = 0.4  // 최소 크기 (40%)
    private let maxScale: CGFloat = 4.0  // 최대 크기 (400%)

    init(
        id: Int,
        position: Binding<CGPoint>,
        scale: Binding<CGFloat>,
        rotation: Binding<Double>,
        onActivate: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self._position = position
        self._scale = scale
        self._rotation = rotation
        self.onActivate = onActivate
        self.content = content()
    }

    var body: some View {
        content
            // 화면에 보이는 배율도 제한 범위 내에서만 움직이도록 시각적 보정
            .scaleEffect(clampedScale(scale * gestureScale))
            .rotationEffect(Angle(degrees: rotation) + gestureRotation)
            .offset(x: position.x + gestureOffset.width, y: position.y + gestureOffset.height)
            .highPriorityGesture(
                SimultaneousGesture(
                    DragGesture()
                        .updating($gestureOffset) { v, s, _ in
                            s = v.translation
                            onActivate()
                        }
                        .onEnded { v in
                            position.x += v.translation.width
                            position.y += v.translation.height
                        },
                    MagnificationGesture()
                        .updating($gestureScale) { v, s, _ in s = v }
                        .onEnded { v in
                            // 제스처 종료 시 최종 scale 값을 제한 범위 내로 고정
                            let newScale = scale * v
                            scale = min(max(newScale, minScale), maxScale)
                        }
                )
            )
            .simultaneousGesture(
                RotationGesture()
                    .updating($gestureRotation) { v, s, _ in s = v }
                    .onEnded { v in rotation += v.degrees }
            )
    }
    
    // 시각적으로 이미지가 너무 작아져서 사라지는 것을 방지하는 보조 함수
    private func clampedScale(_ current: CGFloat) -> CGFloat {
        return min(max(current, minScale * 0.8), maxScale * 1.2)
    }
}
