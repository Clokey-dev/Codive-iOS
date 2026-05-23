//
//  ZoomRotateDragView.swift
//  PinchGesture
//
//  Created by 한금준 on 1/19/26.
//

import SwiftUI

struct ZoomRotateDragView<Content: View>: View {
    let id: Int64
    @Binding var position: CGPoint
    @Binding var scale: CGFloat
    @Binding var rotation: Double
    let isSelected: Bool

    let onActivate: () -> Void
    let onTap: () -> Void
    let content: Content

    @GestureState private var gestureOffset: CGSize = .zero
    @State private var isHandleDragging: Bool = false

    // 핸들 드래그 시 초기값
    @State private var handleStartPos: CGPoint = .zero
    @State private var handleInitialScale: CGFloat = 1.0
    @State private var handleInitialRotation: Double = 0

    // MARK: - 제약 조건
    private let minScale: CGFloat = 0.3
    private let maxScale: CGFloat = 4.0
    private let itemSize: CGFloat = 180
    private let handleSize: CGFloat = 28

    init(
        id: Int64,
        position: Binding<CGPoint>,
        scale: Binding<CGFloat>,
        rotation: Binding<Double>,
        isSelected: Bool,
        onActivate: @escaping () -> Void,
        onTap: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self._position = position
        self._scale = scale
        self._rotation = rotation
        self.isSelected = isSelected
        self.onActivate = onActivate
        self.onTap = onTap
        self.content = content()
    }

    var body: some View {
        content
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                        )
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .frame(width: itemSize, height: itemSize)
                }
            }
            .scaleEffect(scale)
            .rotationEffect(Angle(degrees: rotation))
            .overlay {
                // 핸들 (scale/rotation 밖 — 위치를 직접 계산)
                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                        .frame(width: handleSize, height: handleSize)
                        .offset(cornerOffset)
                        .highPriorityGesture(handleDragGesture)
                        .allowsHitTesting(true)
                }
            }
        .offset(
            x: position.x + gestureOffset.width,
            y: position.y + gestureOffset.height
        )
        .onTapGesture { onTap() }
        .gesture(isHandleDragging ? nil : dragGesture)
    }

    // MARK: - 핸들 위치 (스크린 좌표 기준 우하단 모서리)
    private var cornerOffset: CGSize {
        let half = (itemSize / 2) * scale
        let rad = CGFloat(rotation * .pi / 180)
        return CGSize(
            width: half * cos(rad) - half * sin(rad),
            height: half * sin(rad) + half * cos(rad)
        )
    }

    // MARK: - 본체 드래그 (위치 이동)
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($gestureOffset) { value, state, _ in
                state = value.translation
                onActivate()
            }
            .onEnded { value in
                position.x += value.translation.width
                position.y += value.translation.height
            }
    }

    // MARK: - 핸들 드래그 (스케일 + 회전)
    private var handleDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isHandleDragging {
                    isHandleDragging = true
                    // 드래그 시작: 핸들의 현재 스크린 위치 저장
                    let half = (itemSize / 2) * scale
                    let rad = CGFloat(rotation * .pi / 180)
                    handleStartPos = CGPoint(
                        x: half * cos(rad) - half * sin(rad),
                        y: half * sin(rad) + half * cos(rad)
                    )
                    handleInitialScale = scale
                    handleInitialRotation = rotation
                }

                // 현재 핸들 위치 (스크린 좌표, 아이템 중심 기준)
                let currentX = handleStartPos.x + value.translation.width
                let currentY = handleStartPos.y + value.translation.height

                // 초기 거리 & 현재 거리 → 스케일
                let initDist = sqrt(handleStartPos.x * handleStartPos.x + handleStartPos.y * handleStartPos.y)
                let newDist = sqrt(currentX * currentX + currentY * currentY)

                guard initDist > 0 else { return }

                let newScale = handleInitialScale * (newDist / initDist)
                scale = min(max(newScale, minScale), maxScale)

                // 초기 각도 & 현재 각도 → 회전
                let initAngle = atan2(Double(handleStartPos.y), Double(handleStartPos.x))
                let newAngle = atan2(Double(currentY), Double(currentX))
                let angleDiff = (newAngle - initAngle) * 180 / .pi
                rotation = handleInitialRotation + angleDiff
            }
            .onEnded { _ in
                isHandleDragging = false
            }
    }
}
