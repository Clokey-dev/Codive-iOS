//
//  monthlyDataView.swift
//  Codive
//
//  Created by 한태빈 on 12/19/25.
//

import SwiftUI

struct MonthlyDataView: View {
    @StateObject private var viewModel = MonthlyDataViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                CustomNavigationBar(title: viewModel.reportTitle) {
                    // 뒤로가기 액션
                }
                .background(Color.Codive.grayscale7)
                
                header
                    .padding(.top, 4)
                
                FavoriteByCategory(items: viewModel.favoriteCategories)
                    .padding(.top, 40)
                
                ItemData(stats: viewModel.itemStats)
                    .padding(.top, 40)
                
                WearingData(stats: viewModel.wardrobeUsage)
                    .padding(.top, 40)
                
                Spacer(minLength: 12)
            }
        }
        .background(Color.Codive.grayscale7)
    }
    
    private var header: some View {
        Text(viewModel.dateRangeString)
            .font(.codive_body2_medium)
            .foregroundStyle(Color.Codive.grayscale3)
            .padding(.horizontal, 20)
    }
}

// MARK: - 공통 섹션 헤더
private struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
            
            Image("info")
                .font(.system(size: 18))
                .foregroundStyle(Color.Codive.grayscale4)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 공통 카드 컨테이너
private struct CardContainer<Content: View>: View {
    let height: CGFloat?
    @ViewBuilder let content: Content
    
    init(height: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: height)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
    }
}

// MARK: - FavoriteByCategory
struct FavoriteByCategory: View {
    let items: [CategoryFavoriteItem]
    // NavigationRouter 사용 (MonthlyDataView 상위에서 주입하거나 EnvironmentObject 사용)
    @EnvironmentObject private var navigationRouter: NavigationRouter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "카테고리별 최애 아이템")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        FavoriteDonutCard(
                            categoryTitle: item.categoryName,
                            segments: item.items
                        )
                        .frame(width: 300, height: 182)
                        .onTapGesture {
                            navigationRouter.navigate(to: AppDestination.wardrobeFavorite(items: items))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 2)
            }
        }
    }
}

private struct FavoriteDonutCard: View {
    
    let categoryTitle: String
    let segments: [DonutSegment]
    
    @State private var selectedID: DonutSegment.ID?
    
    private var total: Double {
        segments.map(\.value).reduce(0, +)
    }
    
    private var selectedPercentText: String {
        guard let selectedID else { return "" }
        guard let seg = segments.first(where: { $0.id == selectedID }) else { return "" }
        guard total > 0 else { return "0%" }
        let percent = Int(round((seg.value / total) * 100))
        return "\(percent)%"
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 18) {
                ZStack {
                    DonutChartView(
                        segments: segments,
                        selectedID: $selectedID,
                        thickness: 30,
                        gapDegrees: 5
                    ) {
                        Text(categoryTitle)
                            .font(.codive_title2)
                            .foregroundStyle(Color.Codive.grayscale1)
                    }
                    .frame(width: 120, height: 120)
                    
                    PercentBubbleView(text: selectedPercentText)
                        .offset(x: 36, y: -42)
                        .opacity(selectedID == nil ? 0 : 1)
                        .allowsHitTesting(false)
                }
                
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(segments, id: \.id) { row in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(row.color)
                                .frame(width: 16, height: 16)
                            
                            if let name = row.payload {
                                Text(name)
                                    .font(.codive_body2_medium)
                                    .foregroundStyle(Color.Codive.grayscale1)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(16)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.Codive.grayscale4)
                .padding(.trailing, 16)
                .padding(.top, 18)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .onAppear {
            selectedID = segments.first?.id
        }
    }
}

private struct PercentBubbleView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.codive_body3_medium)
            .foregroundStyle(Color.Codive.grayscale1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                SpeechBubbleShape()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
    }
}

// MARK: - ItemData
struct ItemData: View {
    let stats: [ItemUsageStat]
    @State private var selectedIndex: Int? = nil // 선택된 막대 인덱스
    @EnvironmentObject private var navigationRouter: NavigationRouter
    
    private let maxBarHeight: CGFloat = 140
    
    // 가장 많이 입은 횟수를 기준으로 높이 비율 계산
    private var maxCount: Int {
        stats.map(\.usageCount).max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "옷장 아이템 통계")
            
            CardContainer(height: 230) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .bottom, spacing: 16) {
                        ForEach(Array(stats.enumerated()), id: \.offset) { idx, item in
                            VStack(spacing: 8) {
                                // 횟수 표시
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(barColor(for: idx))
                                    .frame(height: max(8, CGFloat(item.usageCount) / CGFloat(maxCount) * maxBarHeight))
                                
                                Text(item.itemName)
                                    .font(.codive_body3_medium)
                                    .foregroundStyle(Color.Codive.grayscale3)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(height: maxBarHeight)
                }
            }
            .onTapGesture {
                navigationRouter.navigate(to: AppDestination.wardrobeItemStats(stats: stats))
            }
        }
    }
    
    private func barColor(for index: Int) -> Color {
        switch index {
        case 0: return Color.Codive.point1
        case 1: return Color.Codive.point2
        case 2: return Color.Codive.point3
        default: return Color.Codive.grayscale5
        }
    }
}

// MARK: - WearingData
struct WearingData: View {
    let stats: WardrobeUsageStat
    @State private var selectedID: DonutSegment.ID? = nil
    @EnvironmentObject private var navigationRouter: NavigationRouter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "옷장 활용도 체크")
            
            CardContainer(height: 198) {
                HStack(spacing: 18) {
                    usageChart
                        .frame(width: 170, alignment: .leading)
                    
                    Text("보관 중인 가을 옷 \(stats.totalCount)벌 중\n\(stats.wornCount)벌을 실제로 입었어요")
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
                        .lineSpacing(4)
                    
                    Spacer(minLength: 0)
                }
            }
            .onTapGesture {
                navigationRouter.navigate(to: AppDestination.wardrobeUsage(stats: stats))
            }
        }
    }
    
    private var usageChart: some View {
        let safeTotal = max(0, stats.totalCount)
        let safeWorn = max(0, min(stats.wornCount, safeTotal))
        let notWorn = max(0, safeTotal - safeWorn)
        
        let segments: [DonutSegment] = [
            DonutSegment(value: Double(safeWorn), color: Color.Codive.point1, payload: "입음"),
            DonutSegment(value: Double(notWorn), color: Color(red: 0.97, green: 0.92, blue: 0.86), payload: "미착용")
        ]
        
        return VStack(spacing: 10) {
            DonutChartView(
                segments: segments,
                selectedID: $selectedID,
                thickness: 30,
                gapDegrees: 0
            ) {
                Text("\(stats.usagePercent)%")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.Codive.point1)
            }
            .frame(width: 130, height: 130)
            
            HStack(spacing: 4) {
                Text("(")
                    .font(.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale3)
                
                Text("\(safeWorn)벌")
                    .font(.codive_body2_medium)
                    .foregroundStyle(Color.Codive.point1)
                
                Text(" / \(safeTotal)벌)")
                    .font(.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale3)
            }
        }
        .onAppear {
            selectedID = nil
        }
    }
}

//
// DonutChartView에서 말풍선 사용을 위한 Shape
//
private struct SpeechBubbleShape: Shape {
    
    let radius: CGFloat = 8
    let tailSize: CGFloat = 4
    let tailWidth: CGFloat = 12
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bubbleHeight = rect.height - tailSize
        
        path.move(to: CGPoint(x: radius, y: 0))
        
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - radius, y: radius),
                    radius: radius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.width, y: bubbleHeight - radius))
        path.addArc(center: CGPoint(x: rect.width - radius, y: bubbleHeight - radius),
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.midX + (tailWidth / 2), y: bubbleHeight))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        path.addLine(to: CGPoint(x: rect.midX - (tailWidth / 2), y: bubbleHeight))
        
        path.addLine(to: CGPoint(x: radius, y: bubbleHeight))
        path.addArc(center: CGPoint(x: radius, y: bubbleHeight - radius),
                    radius: radius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(center: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        
        return path
    }
}

#Preview {
    MonthlyDataView()
        .environmentObject(NavigationRouter())
}
