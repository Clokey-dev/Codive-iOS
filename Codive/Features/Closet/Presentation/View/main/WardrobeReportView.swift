//
//  WardrobeReportView.swift
//  Codive
//
//  Created by 황상환 on 12/14/25.
//

import SwiftUI

struct WardrobeReportView: View {
    
    // MARK: - Properties
    @State private var selectedSection: Int? = 1
    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    let gap: Double = 5.0
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("9월 옷장 리포트")
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                
                Text("내 옷장에서 발견한 패턴, 지금 확인해보세요!")
                    .font(.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale3)
            }
            .padding(.horizontal, 20)
            
            VStack {
                ZStack {
                    ZStack {
                        ChartSegment(
                            color: Color.Codive.point1,
                            startAngle: 0,
                            endAngle: 0.35 * 360 - gap,
                            index: 1,
                            selectedIndex: $selectedSection
                        )
                        
                        ChartSegment(
                            color: Color.Codive.point2,
                            startAngle: 0.35 * 360,
                            endAngle: 0.65 * 360 - gap,
                            index: 2,
                            selectedIndex: $selectedSection
                        )
                        
                        ChartSegment(
                            color: Color.Codive.point3,
                            startAngle: 0.65 * 360,
                            endAngle: 1.0 * 360 - gap,
                            index: 3,
                            selectedIndex: $selectedSection
                        )
                    }
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    
                    Group {
                        ReportBubbleView(text: "제일 많은 옷은?")
                            .offset(x: 85, y: -60)
                            .scaleEffect(selectedSection == 1 ? 1.08 : 1.0)
                            .animation(.spring(), value: selectedSection)
                        
                        ReportBubbleView(text: "가을 옷은 충분할까?")
                            .offset(x: -85, y: 0)
                            .scaleEffect(selectedSection == 3 ? 1.08 : 1.0)
                            .animation(.spring(), value: selectedSection)
                        
                        ReportBubbleView(text: "쇼핑하면 좋을 옷은?")
                            .offset(x: 85, y: 60)
                            .scaleEffect(selectedSection == 2 ? 1.08 : 1.0)
                            .animation(.spring(), value: selectedSection)
                    }
                    .allowsHitTesting(false)
                }
                .frame(height: 230)
                .onReceive(timer) { _ in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        if let current = selectedSection {
                            selectedSection = (current % 3) + 1
                        } else {
                            selectedSection = 1
                        }
                    }
                }
                
                CustomButton(text: "분석 결과 보기", widthType: .fixed) {
                    // TODO: 분석 결과 화면 연결
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.Codive.grayscale7)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - ChartSegment
struct ChartSegment: View {
    
    // MARK: - Properties
    let color: Color
    let startAngle: Double
    let endAngle: Double
    let index: Int
    @Binding var selectedIndex: Int?
    
    private var isSelected: Bool { selectedIndex == index }
    
    let thickness: CGFloat = 45
    let cornerRadius: CGFloat = 4
    
    // MARK: - Body
    var body: some View {
        let strokeWidth = cornerRadius * 2
        let inset = cornerRadius
        
        ZStack {
            SectorShape(
                startAngle: startAngle,
                endAngle: endAngle,
                innerRadius: (120 - thickness) / 2 + inset,
                outerRadius: (120 + thickness) / 2 - inset
            )
            .fill(color)
            
            SectorShape(
                startAngle: startAngle,
                endAngle: endAngle,
                innerRadius: (120 - thickness) / 2 + inset,
                outerRadius: (120 + thickness) / 2 - inset
            )
            .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .butt, lineJoin: .round))
        }
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .zIndex(isSelected ? 1 : 0)
        .onTapGesture {
            withAnimation(.spring()) {
                selectedIndex = index
            }
        }
    }
}

// MARK: - SectorShape
struct SectorShape: Shape {
    
    // MARK: - Properties
    var startAngle: Double
    var endAngle: Double
    var innerRadius: CGFloat
    var outerRadius: CGFloat
    
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle, endAngle) }
        set { startAngle = newValue.first; endAngle = newValue.second }
    }
    
    // MARK: - Path
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let startRad = startAngle * .pi / 180
        let endRad = endAngle * .pi / 180
        
        path.addArc(center: center, radius: outerRadius, startAngle: Angle(radians: startRad), endAngle: Angle(radians: endRad), clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: Angle(radians: endRad), endAngle: Angle(radians: startRad), clockwise: true)
        path.closeSubpath()
        return path
    }
}

// MARK: - ReportBubbleView
struct ReportBubbleView: View {
    
    // MARK: - Properties
    let text: String
    
    // MARK: - Body
    var body: some View {
        Text(text)
            .font(.codive_body3_regular)
            .foregroundStyle(Color.Codive.grayscale1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .padding(.bottom, 4)
            .background(
                SpeechBubbleShape()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
    }
}

#Preview {
    WardrobeReportView()
}
