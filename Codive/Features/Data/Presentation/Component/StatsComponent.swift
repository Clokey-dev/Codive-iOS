//
//  statsComponent.swift
//  Codive
//
//  Created by 황상환 on 12/14/25.
//

import SwiftUI

// 재사용 데이터 모델
struct DonutSegment: Identifiable, Hashable {
    let id: UUID = .init()
    let value: Double
    let color: Color
    var payload: String? = nil   // 필요하면 카테고리명, id 등 추가로 실어두기
}

// 재사용 도넛 차트
struct DonutChartView<CenterContent: View>: View {

    let segments: [DonutSegment]
    @Binding var selectedID: DonutSegment.ID?

    var thickness: CGFloat = 45
    var gapDegrees: Double = 5
    var cornerRadius: CGFloat = 4
    var rotationDegrees: Double = -90
    var selectedScale: CGFloat = 1.08

    @ViewBuilder var centerContent: () -> CenterContent

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let outerRadius = size / 2
            let innerRadius = max(0, outerRadius - thickness)

            ZStack {
                ForEach(computedSegments(totalSize: size, innerRadius: innerRadius, outerRadius: outerRadius)) { item in
                    DonutSegmentView(
                        color: item.segment.color,
                        startAngle: item.startAngle,
                        endAngle: item.endAngle,
                        innerRadius: item.innerRadius,
                        outerRadius: item.outerRadius,
                        cornerRadius: cornerRadius,
                        isSelected: selectedID == item.segment.id,
                        selectedScale: selectedScale
                    )
                    .zIndex((selectedID == item.segment.id) ? 1 : 0)
                    .onTapGesture {
                        withAnimation(.spring()) {
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

    // 각 세그먼트의 시작/끝 각도 계산
    private func computedSegments(
        totalSize: CGFloat,
        innerRadius: CGFloat,
        outerRadius: CGFloat
    ) -> [ComputedSegment] {

        let total = segments.map(\.value).reduce(0, +)
        guard total > 0, segments.isEmpty == false else { return [] }

        let n = Double(segments.count)

        // gap이 너무 커서 available이 음수가 되지 않도록 방어
        let safeGap = max(0, min(gapDegrees, (360.0 / n) * 0.6))
        let available = 360.0 - safeGap * n

        var current = 0.0
        var result: [ComputedSegment] = []

        for seg in segments {
            let portion = seg.value / total
            let span = max(0, available * portion)

            let start = current
            let end = current + span

            result.append(
                ComputedSegment(
                    segment: seg,
                    startAngle: start,
                    endAngle: end,
                    innerRadius: innerRadius,
                    outerRadius: outerRadius
                )
            )

            current = end + safeGap
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

        init(segment: DonutSegment, startAngle: Double, endAngle: Double, innerRadius: CGFloat, outerRadius: CGFloat) {
            self.id = segment.id
            self.segment = segment
            self.startAngle = startAngle
            self.endAngle = endAngle
            self.innerRadius = innerRadius
            self.outerRadius = outerRadius
        }
    }
}

// 세그먼트 뷰 (기존 ChartSegment 역할)
private struct DonutSegmentView: View {
    let color: Color
    let startAngle: Double
    let endAngle: Double
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    let cornerRadius: CGFloat
    let isSelected: Bool
    let selectedScale: CGFloat

    var body: some View {
        let strokeWidth = cornerRadius * 2
        let inset = cornerRadius

        ZStack {
            SectorShape(
                startAngle: startAngle,
                endAngle: endAngle,
                innerRadius: innerRadius + inset,
                outerRadius: outerRadius - inset
            )
            .fill(color)

            SectorShape(
                startAngle: startAngle,
                endAngle: endAngle,
                innerRadius: innerRadius + inset,
                outerRadius: outerRadius - inset
            )
            .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .butt, lineJoin: .round))
        }
        .scaleEffect(isSelected ? selectedScale : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

// 섹터 Shape (rect 기반으로만 path 생성)
private struct SectorShape: Shape {
    var startAngle: Double
    var endAngle: Double
    var innerRadius: CGFloat
    var outerRadius: CGFloat

    var animatableData: AnimatablePair<Double, Double> {
        get { .init(startAngle, endAngle) }
        set { startAngle = newValue.first; endAngle = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let startRad = startAngle * .pi / 180
        let endRad = endAngle * .pi / 180

        path.addArc(center: center, radius: outerRadius,
                    startAngle: Angle(radians: startRad),
                    endAngle: Angle(radians: endRad),
                    clockwise: false)

        path.addArc(center: center, radius: innerRadius,
                    startAngle: Angle(radians: endRad),
                    endAngle: Angle(radians: startRad),
                    clockwise: true)

        path.closeSubpath()
        return path
    }
}
