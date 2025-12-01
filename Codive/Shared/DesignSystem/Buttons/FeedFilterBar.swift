//
//  FeedFilterBar.swift
//  Codive
//
//  Created by 황상환 on 12/1/25.
//

import SwiftUI

struct FeedFilterBar: View {
    
    // MARK: - Properties
    let categories: [String]
    @Binding var selectedCategory: String
    var onFilterTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        let isFollowing = category == "팔로잉"
                        let isSelected = selectedCategory == category
                        
                        let activeTextColor = isFollowing ? Color.white : Color.Codive.point1
                        let activeBgColor = isFollowing ? Color.Codive.main0 : Color.Codive.point4
                        let activeStrokeColor = isFollowing ? Color.Codive.main0 : Color.Codive.point2
                        
                        FilterSelectionButton(
                            title: category,
                            isSelected: isSelected,
                            activeTextColor: activeTextColor,
                            activeBackgroundColor: activeBgColor,
                            activeStrokeColor: activeStrokeColor
                        ) {
                            if selectedCategory == category {
                                selectedCategory = ""
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
                
                Button(action: onFilterTap) {
                    ZStack {
                        Circle()
                            .stroke(Color.Codive.grayscale5, lineWidth: 1)
                            .background(Circle().fill(Color.white))
                            .frame(width: 32, height: 32)
                        
                        Image("filter_black")
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

// MARK: - Selection Button
private struct FilterSelectionButton: View {
    
    // MARK: - Properties
    let title: String
    let isSelected: Bool
    let activeTextColor: Color
    let activeBackgroundColor: Color
    let activeStrokeColor: Color
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.codive_body2_medium)
                .foregroundStyle(isSelected ? activeTextColor : Color.Codive.grayscale1)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? activeBackgroundColor : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(isSelected ? activeStrokeColor : Color.Codive.grayscale5, lineWidth: isSelected ? 1 : 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 100))
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        FeedFilterBar(
            categories: ["팔로잉", "미니멀", "캐주얼", "스트릿", "빈티지"],
            selectedCategory: .constant("팔로잉"),
            onFilterTap: {}
        )
        
        FeedFilterBar(
            categories: ["팔로잉", "미니멀", "캐주얼", "스트릿", "빈티지"],
            selectedCategory: .constant("미니멀"),
            onFilterTap: {}
        )
    }
}
