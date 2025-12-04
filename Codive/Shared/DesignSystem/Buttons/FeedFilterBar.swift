//
//  FeedFilterBar.swift
//  Codive
//
//  Created by 황상환 on 12/1/25.
//

import SwiftUI

struct FeedFilterBar: View {
    
    // MARK: - Properties
    @Binding var isFollowingSelected: Bool
    let categories: [String]
    @Binding var selectedCategory: String
    var onFilterTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // 팔로우 버튼
                    FollowingButton(isSelected: $isFollowingSelected)
                    
                    // 스타일 카테고리 버튼
                    ForEach(categories, id: \.self) { category in
                        let isSelected = selectedCategory == category
                        
                        FilterSelectionButton(
                            title: category,
                            isSelected: isSelected
                        ) {
                            if selectedCategory == category {
                                selectedCategory = "" // Deselect
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 12)
            }
            
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.Codive.grayscale5)
                    .frame(width: 1, height: 24)
                
                Button {
                    onFilterTap()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.Codive.grayscale5, lineWidth: 1)
                            .background(Circle().fill(Color.white))
                            .frame(width: 32, height: 32)
                        
                        Image("filter_brown")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(.trailing, 20)
            .background(Color.white)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Following Button
private struct FollowingButton: View {
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .semibold))
                Text("팔로잉")
            }
            .font(.codive_body2_medium)
            .foregroundStyle(isSelected ? .white : Color.Codive.main0)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.Codive.main0 : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(isSelected ? Color.Codive.main0 : Color.Codive.grayscale5, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 100))
        }
    }
}

// MARK: - Style Filter Button
private struct FilterSelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let activeTextColor = Color.Codive.point1
    private let activeBgColor = Color.Codive.point4
    private let activeStrokeColor = Color.Codive.point2
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.codive_body2_medium)
                .foregroundStyle(isSelected ? activeTextColor : Color.Codive.grayscale1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? activeBgColor : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(isSelected ? activeStrokeColor : Color.Codive.grayscale5, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 100))
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        FeedFilterBar(
            isFollowingSelected: .constant(true),
            categories: ["미니멀", "캐주얼", "스트릿", "빈티지"],
            selectedCategory: .constant("")
        ) {}
        
        FeedFilterBar(
            isFollowingSelected: .constant(false),
            categories: ["미니멀", "캐주얼", "스트릿", "빈티지"],
            selectedCategory: .constant("미니멀")
        ) {}
    }
}
