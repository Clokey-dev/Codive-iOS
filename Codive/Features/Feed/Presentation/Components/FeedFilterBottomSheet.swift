//
//  FeedFilterBottomSheet.swift
//  Codive
//
//  Created by 황상환 on 12/1/25.
//

import SwiftUI

struct FeedFilterBottomSheet: View {
    
    // MARK: - Properties
    @Binding var selectedStyles: Set<String>
    @Binding var selectedSituations: Set<String>
    
    var onReset: () -> Void
    var onApply: () -> Void
    
    private let styleOptions = [
        TextLiteral.Add.styleLoving, TextLiteral.Add.styleMinimal, TextLiteral.Add.styleVintage,
        TextLiteral.Add.styleSporty, TextLiteral.Add.styleStreet, TextLiteral.Add.styleChic,
        TextLiteral.Add.styleOffice, TextLiteral.Add.styleCasual, TextLiteral.Add.styleClassic,
        TextLiteral.Add.styleHighteen
    ]
    private let situationOptions = [
        TextLiteral.Add.situationDate, TextLiteral.Add.situationDaily, TextLiteral.Add.situationTravel,
        TextLiteral.Add.situationExercise, TextLiteral.Add.situationFestival, TextLiteral.Add.situationWork,
        TextLiteral.Add.situationParty
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.Codive.grayscale5)
                .frame(width: 40, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 24)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    FilterSectionView(
                        title: "관심 스타일",
                        description: "좋아하는 스타일을 등록해두면, 피드에서 손쉽게 골라볼 수 있어요.",
                        options: styleOptions,
                        selections: $selectedStyles,
                        maxCount: 5
                    )

                    FilterSectionView(
                        title: "상황",
                        description: "필요한 상황을 등록해두면, 피드에서 손쉽게 골라볼 수 있어요.",
                        options: situationOptions,
                        selections: $selectedSituations,
                        maxCount: 5
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            
            // Bottom Buttons
            HStack(spacing: 12) {
                CustomButton(
                    text: TextLiteral.Home.reset,
                    widthType: .half,
                    styleType: .border,
                    action: onReset
                )
                
                CustomButton(
                    text: TextLiteral.Home.apply,
                    widthType: .half,
                    styleType: .fill,
                    action: onApply
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .customCornerRadius(20, corners: [.topLeft, .topRight])
    }
}

// MARK: - Subviews

private struct FilterSectionView: View {
    let title: String
    let description: String
    let options: [String]
    @Binding var selections: Set<String>
    let maxCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                // 타이틀
                Text("\(title) (\(selections.count)/\(maxCount))")
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                
                // 설명
                Text(description)
                    .font(.codive_body3_regular)
                    .foregroundStyle(Color.Codive.grayscale3)
            }
            
            CustomFlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        toggleSelection(option)
                    }) {
                        Text(option)
                    }
                    .buttonStyle(SelectionButtonStyle(isSelected: selections.contains(option)))
                }
            }
        }
    }
    
    private func toggleSelection(_ option: String) {
        if selections.contains(option) {
            selections.remove(option)
        } else {
            if selections.count >= maxCount { return }
            selections.insert(option)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.opacity(0.3).ignoresSafeArea()
        
        VStack {
            Spacer()
            FeedFilterBottomSheet(
                selectedStyles: .constant(["미니멀", "캐주얼"]),
                selectedSituations: .constant([]),
                onReset: {},
                onApply: {}
            )
        }
    }
}
