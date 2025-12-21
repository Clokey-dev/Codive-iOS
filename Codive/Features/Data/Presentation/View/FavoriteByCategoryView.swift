//
//  FavoriteByCategoryView.swift
//  Codive
//
//  Created by 한태빈 on 12/19/25.
//
import SwiftUI

struct FavoriteByCategoryView: View {
    let items: [CategoryFavoriteItem]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CustomNavigationBar(title: "카테고리 통계") {
                dismiss()
            }
            .background(Color.Codive.grayscale7)

            Text("그래프를 눌러 구체적인 히스토리를 살펴보세요")
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale3)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 12)

            ScrollView {
                VStack(spacing: 28) {
                    ForEach(items) { item in
                        CategoryDonutSection(item: item)
                    }
                }
                .padding(.top, 22)
                .padding(.bottom, 24)
            }
        }
        .background(Color("white"))
        .navigationBarHidden(true)
    }
}

private struct CategoryDonutSection: View {
    let item: CategoryFavoriteItem
    @State private var selectedID: DonutSegment.ID?

    private var total: Double {
        item.items.map(\.value).reduce(0, +)
    }

    private var selectedSegment: DonutSegment? {
        guard let selectedID else { return nil }
        return item.items.first(where: { $0.id == selectedID })
    }

    private var selectedPercent: Int {
        guard let seg = selectedSegment, total > 0 else { return 0 }
        return Int(round((seg.value / total) * 100))
    }

    var body: some View {
        ZStack {
            DonutChartView(
                segments: item.items,
                selectedID: $selectedID,
                thickness: 50,
                gapDegrees: 5
            ) {
                Text(item.categoryName)
                    .font(.codive_title1)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
            .frame(width: 196, height: 196)

            if let seg = selectedSegment {
                BubbleLabelView(
                    title: seg.payload ?? "",
                    percent: selectedPercent
                )
                .offset(x: 68, y: -62)
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .onAppear {
            selectedID = item.items.first?.id
        }
    }
}

private struct BubbleLabelView: View {
    let title: String
    let percent: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)

            Text("\(percent)%")
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            SpeechBubbleShape()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
        )
    }
}

private struct SpeechBubbleShape: Shape {
    let radius: CGFloat = 10
    let tailSize: CGFloat = 6
    let tailWidth: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bubbleHeight = rect.height - tailSize

        path.move(to: CGPoint(x: radius, y: 0))

        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addArc(
            center: CGPoint(x: rect.width - radius, y: radius),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.width, y: bubbleHeight - radius))
        path.addArc(
            center: CGPoint(x: rect.width - radius, y: bubbleHeight - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.midX + (tailWidth / 2), y: bubbleHeight))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        path.addLine(to: CGPoint(x: rect.midX - (tailWidth / 2), y: bubbleHeight))

        path.addLine(to: CGPoint(x: radius, y: bubbleHeight))
        path.addArc(
            center: CGPoint(x: radius, y: bubbleHeight - radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(
            center: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        return path
    }
}

#Preview {
    FavoriteByCategoryView(items: [
        CategoryFavoriteItem(
            categoryName: "상의",
            items: [
                DonutSegment(value: 5, color: Color.Codive.point1, payload: "맨투맨"),
                DonutSegment(value: 3, color: Color.Codive.point2, payload: "후드티"),
                DonutSegment(value: 2, color: Color.Codive.point3, payload: "셔츠")
            ]
        ),
    ])
}
