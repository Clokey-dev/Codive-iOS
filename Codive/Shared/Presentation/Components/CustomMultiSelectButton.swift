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
            CustomFlowLayout(spacing: 8) {
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

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        CustomMultiSelectButton(
            title: "계절",
            options: ["봄", "여름", "가을", "겨울"],
            selectedOptions: .constant(["봄", "여름"]),
            maxSelection: 4,
            showRequiredMark: true
        )
        
        CustomMultiSelectButton(
            title: "스타일",
            options: ["캐주얼", "포멀", "스트릿", "빈티지", "미니멀"],
            selectedOptions: .constant(["캐주얼"]),
            maxSelection: 3,
            showRequiredMark: false
        )
    }
    .padding(20)
}
