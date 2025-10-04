//
//  CustomMultiSelectButton.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

struct CustomMultiSelectButton: View {
    
    // MARK: - Properties
    let title: String
    let options: [String]
    @Binding var selectedOptions: Set<String>
    let maxSelection: Int?
    let showRequiredMark: Bool
    
    // MARK: - Initializer
    init(
        title: String,
        options: [String],
        selectedOptions: Binding<Set<String>>,
        maxSelection: Int? = nil,
        showRequiredMark: Bool = false
    ) {
        self.title = title
        self.options = options
        self._selectedOptions = selectedOptions
        self.maxSelection = maxSelection
        self.showRequiredMark = showRequiredMark
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Title with selection count
            HStack(alignment: .top, spacing: 4) {
                if let maxSelection = maxSelection {
                    Text("\(title) (\(selectedOptions.count)/\(maxSelection))")
                        .font(.codive_title2)
                        .foregroundColor(Color.Codive.grayscale1)
                } else {
                    Text(title)
                        .font(.codive_title2)
                        .foregroundColor(Color.Codive.grayscale1)
                }
                
                if showRequiredMark {
                    Text("*")
                        .font(.codive_title2)
                        .foregroundColor(Color.Codive.point1)
                        .offset(x: -4, y: -4)
                }
            }
            
            // Selection Buttons
            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    SelectionButton(
                        title: option,
                        isSelected: selectedOptions.contains(option)
                    ) {
                        toggleSelection(option)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func toggleSelection(_ option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            if let maxSelection = maxSelection, selectedOptions.count >= maxSelection {
                return
            }
            selectedOptions.insert(option)
        }
    }
}

// MARK: - Selection Button
private struct SelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.codive_body2_medium)
                .foregroundColor(isSelected ? Color.Codive.point1 : Color.Codive.grayscale1)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.Codive.point4 : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(isSelected ? Color.Codive.point2 : Color.Codive.grayscale5, lineWidth: isSelected ? 2 : 1)
                )
                .cornerRadius(100)
        }
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        CustomMultiSelectButton(
            title: "오늘의 스타일을 선택해보세요",
            options: ["걸리시", "러블리", "미니멀", "빈티지", "스포티", "스트릿", "시크", "오피스룩", "캐주얼", "클래식", "하이틴"],
            selectedOptions: .constant(["걸리시", "스트릿", "시크"]),
            maxSelection: 3,
            showRequiredMark: true
        )
        
        CustomMultiSelectButton(
            title: "어떤 상황에 주로 입으시나요?",
            options: ["데이트", "데일리", "여행", "운동", "축제", "출근복", "파티"],
            selectedOptions: .constant(["데이트"]),
            maxSelection: nil,
            showRequiredMark: true
        )
    }
    .padding(.horizontal, 20)
    .background(Color.white)
}
