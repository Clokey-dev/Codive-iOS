//
//  CustomAIRecommendationView.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

// MARK: - 옷 정보 모델
struct ClothingItem: Identifiable {
    let id = UUID()
    let imageName: String
    let category: String
    let subcategory: String
    let season: String
    let name: String
    let brand: String
    let purchaseUrl: String
}

// MARK: - CustomAIRecommendationView
struct CustomAIRecommendationView: View {
    
    // MARK: - Properties
    let title: String
    let items: [ClothingItem]
    @Binding var selectedItemIndex: Int
    let onCategoryTap: () -> Void
    let onSeasonTap: () -> Void
        
    // MARK: - Initializer
    init(
        title: String = "AI가 옷 정보를 불러왔어요",
        items: [ClothingItem],
        selectedItemIndex: Binding<Int>,
        onCategoryTap: @escaping () -> Void,
        onSeasonTap: @escaping () -> Void
    ) {
        self.title = title
        self.items = items
        self._selectedItemIndex = selectedItemIndex
        self.onCategoryTap = onCategoryTap
        self.onSeasonTap = onSeasonTap
    }
    
    // 안전한 currentItem 접근
    private var currentItem: ClothingItem? {
        guard !items.isEmpty, items.indices.contains(selectedItemIndex) else {
            return nil
        }
        return items[selectedItemIndex]
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text(title)
                .font(.codive_title1)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.horizontal, 20)
            
            // items가 비어있으면 빈 상태 표시
            if let item = currentItem {
                contentView(for: item)
            } else {
                emptyStateView
            }
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private func contentView(for item: ClothingItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection(for: item)
            formFieldsSection(for: item)
        }
    }
    
    // MARK: - Image Section
    @ViewBuilder
    private func imageSection(for item: ClothingItem) -> some View {
        VStack(spacing: 16) {
            mainImageView(for: item)
            
            if items.count > 1 {
                thumbnailImagesView
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    @ViewBuilder
    private func mainImageView(for item: ClothingItem) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.width)
                    .background(Color.Codive.grayscale6)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                editButton
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var editButton: some View {
        Button {
            // action
        } label: {
            Image(systemName: "pencil")
                .font(.system(size: 16))
                .foregroundStyle(Color.Codive.grayscale2)
                .frame(width: 32, height: 32)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(12)
    }
    
    private var thumbnailImagesView: some View {
        HStack(spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                thumbnailButton(for: item, at: index)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func thumbnailButton(for item: ClothingItem, at index: Int) -> some View {
        Button {
            withAnimation {
                selectedItemIndex = index
            }
        } label: {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 65, height: 65)
                .background(Color.Codive.grayscale6)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            selectedItemIndex == index ? Color.Codive.grayscale3 : Color.Codive.grayscale5,
                            lineWidth: selectedItemIndex == index ? 2 : 1
                        )
                )
        }
    }
    
    // MARK: - Form Fields Section
    @ViewBuilder
    private func formFieldsSection(for item: ClothingItem) -> some View {
        VStack(spacing: 16) {
            CustomTextFieldButton(
                title: "카테고리",
                value: "\(item.category) > \(item.subcategory)",
                showRequiredMark: true,
                action: onCategoryTap
            )
            
            CustomTextFieldButton(
                title: "계절",
                value: item.season,
                showRequiredMark: true,
                action: onSeasonTap
            )
            
            CustomTextField1(
                title: "옷 이름",
                placeholder: "옷 이름을 입력해주세요.",
                text: .constant(item.name)
            )
            
            CustomTextField1(
                title: "브랜드",
                placeholder: "브랜드를 입력해주세요.",
                text: .constant(item.brand)
            )
            
            CustomTextField1(
                title: "구매 url",
                placeholder: "구매 url을 입력해주세요.",
                text: .constant(item.purchaseUrl)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tshirt")
                .font(.system(size: 60))
                .foregroundStyle(Color.Codive.grayscale4)
            
            Text("옷 정보가 없습니다")
                .font(.codive_body1_regular)
                .foregroundStyle(Color.Codive.grayscale3)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .padding(.top, 20)
    }
}

// MARK: - CustomTextFieldButton
struct CustomTextFieldButton: View {
    let title: String
    let value: String
    let showRequiredMark: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            HStack(alignment: .top, spacing: 4) {
                Text(title)
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                
                if showRequiredMark {
                    Text("*")
                        .font(.codive_title2)
                        .foregroundStyle(Color.Codive.point1)
                        .offset(x: -4, y: -4)
                }
            }
            
            // Button (TextField 스타일)
            Button(action: action) {
                HStack {
                    Text(value)
                        .font(.codive_body1_regular)
                        .foregroundStyle(Color.Codive.grayscale1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.Codive.grayscale3)
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.Codive.grayscale5, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        CustomAIRecommendationView(
            items: [
                ClothingItem(
                    imageName: "sample_clothes1",
                    category: "상의",
                    subcategory: "블라우스",
                    season: "봄",
                    name: "핑크 블라우스",
                    brand: "",
                    purchaseUrl: ""
                ),
                ClothingItem(
                    imageName: "sample_clothes2",
                    category: "상의",
                    subcategory: "반팔티",
                    season: "봄, 여름, 가을",
                    name: "블랙 티셔츠",
                    brand: "",
                    purchaseUrl: ""
                ),
                ClothingItem(
                    imageName: "sample_clothes3",
                    category: "아우터",
                    subcategory: "점퍼/바람막이",
                    season: "봄, 가을",
                    name: "민트 셔츠 재킷",
                    brand: "",
                    purchaseUrl: ""
                )
            ],
            selectedItemIndex: .constant(0),
            onCategoryTap: {
                print("카테고리 선택")
            },
            onSeasonTap: {
                print("계절 선택")
            }
        )
        .background(Color.white)
    }
}
