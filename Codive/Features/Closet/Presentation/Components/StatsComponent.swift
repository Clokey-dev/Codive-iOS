//
//  StatsComponent.swift
//  Codive
//
//  Created by 황상환 on 12/14/25.
//

import Foundation
import SwiftUI

// MARK: - DonutSegment Model

struct DonutSegment: Identifiable, Hashable {
    let id: UUID = .init()
    let value: Double
    let color: Color
    var payload: String?
}

// MARK: - DonutChartView

struct DonutChartView<CenterContent: View>: View {

    let segments: [DonutSegment]
    @Binding var selectedID: DonutSegment.ID?

    var thickness: CGFloat = 45
    /// 비선택 세그먼트끼리의 gap (0이면 매끈한 링)
    var gapDegrees: Double = 0
    /// 선택된 세그먼트의 모서리 라운드
    var cornerRadius: CGFloat = 6
    var rotationDegrees: Double = -90
    /// 강조된 세그먼트가 바깥쪽으로 얼마나 튀어나올지
    var selectedOuterExtension: CGFloat = 6
    /// 강조된 세그먼트가 안쪽으로 얼마나 들어갈지 (양쪽 두께 확장으로 강조감 ↑)
    var selectedInnerExtension: CGFloat = 3
    /// 강조된 세그먼트 양옆에 자체 inset(각도)을 줘서 작은 gap을 만든다
    var selectedAngularInset: Double = 2
    /// 비선택 세그먼트 양옆을 살짝 확장해 인접 segment와 겹치게 만듦 (anti-alias 흰선 제거)
    var unselectedOverlapDegrees: Double = 0.4

    @ViewBuilder var centerContent: () -> CenterContent

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            // 강조 시 바깥으로 확장되므로 outer 반지름은 selectedOuterExtension만큼 여유 둠
            let outerRadius = size / 2 - selectedOuterExtension
            let innerRadius = max(0, outerRadius - thickness)

            ZStack {
                ForEach(
                    computedSegments(
                        totalSize: size,
                        innerRadius: innerRadius,
                        outerRadius: outerRadius
                    )
                ) { item in
                    let isSelected = selectedID == item.segment.id
                    let startInset = isSelected ? selectedAngularInset : -unselectedOverlapDegrees
                    let endInset = isSelected ? selectedAngularInset : -unselectedOverlapDegrees
                    DonutSegmentView(
                        color: item.segment.color,
                        startAngle: item.startAngle + startInset,
                        endAngle: item.endAngle - endInset,
                        innerRadius: item.innerRadius - (isSelected ? selectedInnerExtension : 0),
                        outerRadius: item.outerRadius + (isSelected ? selectedOuterExtension : 0),
                        cornerRadius: isSelected ? cornerRadius : 0,
                        isSelected: isSelected
                    )
                    .zIndex(isSelected ? 1 : 0)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedID = item.segment.id
                        }
                    }
                }

                centerContent()
                    .rotationEffect(.degrees(-rotationDegrees))
            }
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotationDegrees))
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Private

    private let maxGapPortion: Double = 0.6

    private func computedSegments(
        totalSize: CGFloat,
        innerRadius: CGFloat,
        outerRadius: CGFloat
    ) -> [ComputedSegment] {

        // 0값 세그먼트 필터링
        let validSegments = segments.filter { $0.value > 0 }
        let total = validSegments.map(\.value).reduce(0, +)
        guard total > 0, !validSegments.isEmpty else { return [] }

        let segmentCount = Double(validSegments.count)
        let safeGap = segmentCount > 1
            ? max(0, min(gapDegrees, (360.0 / segmentCount) * maxGapPortion))
            : 0
        let available = 360.0 - safeGap * segmentCount

        var current = 0.0
        var result: [ComputedSegment] = []

        for seg in validSegments {
            let portion = seg.value / total
            let span = max(0, available * portion)

            result.append(
                ComputedSegment(
                    id: seg.id,
                    segment: seg,
                    startAngle: current,
                    endAngle: current + span,
                    innerRadius: innerRadius,
                    outerRadius: outerRadius
                )
            )
            current += span + safeGap
        }
        return result
    }

    private struct ComputedSegment: Identifiable {
        let id: DonutSegment.ID
        let segment: DonutSegment
        let startAngle: Double
        let endAngle: Double
        let innerRadius: CGFloat
        let outerRadius: CGFloat
    }
}

// MARK: - DonutSegmentView

private struct DonutSegmentView: View {
    let color: Color
    let startAngle: Double
    let endAngle: Double
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    let cornerRadius: CGFloat
    let isSelected: Bool

    var body: some View {
        RoundedDonutSlice(
            startAngle: startAngle,
            endAngle: endAngle,
            innerRadius: innerRadius,
            outerRadius: outerRadius,
            cornerRadius: cornerRadius
        )
        .fill(color)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isSelected)
    }
}

// MARK: - RoundedDonutSlice
// 4개 모서리가 둥근 도넛 한 조각. fill만으로 어긋남 없이 깨끗하게 그려진다.

struct RoundedDonutSlice: Shape {

    var startAngle: Double  // degrees
    var endAngle: Double
    var innerRadius: CGFloat
    var outerRadius: CGFloat
    var cornerRadius: CGFloat

    var animatableData: AnimatablePair<
        AnimatablePair<Double, Double>,
        AnimatablePair<CGFloat, CGFloat>
    > {
        get {
            AnimatablePair(
                AnimatablePair(startAngle, endAngle),
                AnimatablePair(innerRadius, outerRadius)
            )
        }
        set {
            startAngle = newValue.first.first
            endAngle = newValue.first.second
            innerRadius = newValue.second.first
            outerRadius = newValue.second.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let thickness = max(0, outerRadius - innerRadius)
        // 코너 반지름이 두께 절반을 못 넘게 클램프
        let cornerR = max(0, min(cornerRadius, thickness / 2))

        let startRad = startAngle * .pi / 180
        let endRad = endAngle * .pi / 180
        let sweep = endRad - startRad

        // 세그먼트가 너무 작아서 코너 라운드가 들어갈 공간이 없으면 일반 sector로 폴백
        let outerAngularInset = outerRadius > 0 ? cornerR / outerRadius : 0
        let innerAngularInset = innerRadius > 0 ? cornerR / innerRadius : 0
        let totalAngularInset = outerAngularInset * 2
        guard cornerR > 0, sweep > totalAngularInset, innerRadius > 0 else {
            path.addArc(
                center: center, radius: outerRadius,
                startAngle: .radians(startRad), endAngle: .radians(endRad),
                clockwise: false
            )
            path.addArc(
                center: center, radius: innerRadius,
                startAngle: .radians(endRad), endAngle: .radians(startRad),
                clockwise: true
            )
            path.closeSubpath()
            return path
        }

        let outerStart = startRad + outerAngularInset
        let outerEnd = endRad - outerAngularInset
        let innerStart = startRad + innerAngularInset
        let innerEnd = endRad - innerAngularInset

        // 각 코너의 점들 — quadCurve의 시작/끝/control 위치
        func point(angle: Double, radius: CGFloat) -> CGPoint {
            let cosValue: Double = Foundation.cos(angle)
            let sinValue: Double = Foundation.sin(angle)
            return CGPoint(
                x: center.x + CGFloat(cosValue) * radius,
                y: center.y + CGFloat(sinValue) * radius
            )
        }

        // 시작 outer corner
        let p1 = point(angle: startRad, radius: outerRadius - cornerR)
        let p2 = point(angle: outerStart, radius: outerRadius)
        let cp12 = point(angle: startRad, radius: outerRadius)

        // 끝 outer corner
        let p4 = point(angle: endRad, radius: outerRadius - cornerR)
        let cp34 = point(angle: endRad, radius: outerRadius)

        // 끝 inner corner
        let p5 = point(angle: endRad, radius: innerRadius + cornerR)
        let p6 = point(angle: innerEnd, radius: innerRadius)
        let cp56 = point(angle: endRad, radius: innerRadius)

        // 시작 inner corner
        let p8 = point(angle: startRad, radius: innerRadius + cornerR)
        let cp78 = point(angle: startRad, radius: innerRadius)

        path.move(to: p1)
        path.addQuadCurve(to: p2, control: cp12)
        path.addArc(
            center: center, radius: outerRadius,
            startAngle: .radians(outerStart), endAngle: .radians(outerEnd),
            clockwise: false
        )
        path.addQuadCurve(to: p4, control: cp34)
        path.addLine(to: p5)
        path.addQuadCurve(to: p6, control: cp56)
        path.addArc(
            center: center, radius: innerRadius,
            startAngle: .radians(innerEnd), endAngle: .radians(innerStart),
            clockwise: true
        )
        path.addQuadCurve(to: p8, control: cp78)
        path.addLine(to: p1)
        path.closeSubpath()

        return path
    }
}
