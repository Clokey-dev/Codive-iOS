//
//  CustomAIRecommendationView.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

// MARK: - 옷 정보 모델
struct ClothingItem: Identifiable {
    let id: Int
    let imageName: String?
    let image: UIImage?
    let imageUrl: String?
    let category: String
    let subcategory: String
    let season: String
    let name: String
    let brand: String
    let purchaseUrl: String

    init(
        id: Int = 0,
        imageName: String? = nil,
        image: UIImage? = nil,
        imageUrl: String? = nil,
        category: String,
        subcategory: String,
        season: String,
        name: String,
        brand: String,
        purchaseUrl: String
    ) {
        self.id = id
        self.imageName = imageName
        self.image = image
        self.imageUrl = imageUrl
        self.category = category
        self.subcategory = subcategory
        self.season = season
        self.name = name
        self.brand = brand
        self.purchaseUrl = purchaseUrl
    }
}

// MARK: - CustomAIRecommendationView
struct CustomAIRecommendationView: View {

    // MARK: - Properties
    let title: String
    let items: [ClothingItem]
    @Binding var selectedItemIndex: Int
    let onCategoryTap: () -> Void
    let onSeasonTap: () -> Void

    // 버튼 관련 (옵션)
    let onPrevious: (() -> Void)?
    let onNext: (() -> Void)?
    let onComplete: (() -> Void)?
    let isFormValid: Bool
    let isSinglePhoto: Bool
    let isFirstPhoto: Bool
    let isLastPhoto: Bool

    // 텍스트 필드 업데이트 콜백 (옵션)
    let onNameChanged: ((String) -> Void)?
    let onBrandChanged: ((String) -> Void)?
    let onPurchaseUrlChanged: ((String) -> Void)?

    // 유효성 검증 에러 (옵션)
    let showCategoryError: Bool
    let showSeasonError: Bool

    // 완료된 아이템 인덱스 (썸네일 흐림 효과용)
    let completedItemIndices: Set<Int>

    // 썸네일 탭 콜백 (옵션 - 유효성 검증용)
    let onThumbnailTap: ((Int) -> Void)?

    // UI 표시 제어 (옵션)
    let showTitle: Bool
    let showEditButton: Bool

    // 지우개 편집 콜백 (옵션)
    let onEditButtonTap: (() -> Void)?

    // MARK: - Initializer
    init(
        title: String = TextLiteral.Closet.aiRecommendationTitle,
        items: [ClothingItem],
        selectedItemIndex: Binding<Int>,
        onCategoryTap: @escaping () -> Void,
        onSeasonTap: @escaping () -> Void,
        onPrevious: (() -> Void)? = nil,
        onNext: (() -> Void)? = nil,
        onComplete: (() -> Void)? = nil,
        isFormValid: Bool = false,
        isSinglePhoto: Bool = false,
        isFirstPhoto: Bool = false,
        isLastPhoto: Bool = false,
        onNameChanged: ((String) -> Void)? = nil,
        onBrandChanged: ((String) -> Void)? = nil,
        onPurchaseUrlChanged: ((String) -> Void)? = nil,
        showCategoryError: Bool = false,
        showSeasonError: Bool = false,
        completedItemIndices: Set<Int> = [],
        onThumbnailTap: ((Int) -> Void)? = nil,
        showTitle: Bool = true,
        showEditButton: Bool = true,
        onEditButtonTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.items = items
        self._selectedItemIndex = selectedItemIndex
        self.onCategoryTap = onCategoryTap
        self.onSeasonTap = onSeasonTap
        self.onPrevious = onPrevious
        self.onNext = onNext
        self.onComplete = onComplete
        self.isFormValid = isFormValid
        self.isSinglePhoto = isSinglePhoto
        self.isFirstPhoto = isFirstPhoto
        self.isLastPhoto = isLastPhoto
        self.onNameChanged = onNameChanged
        self.onBrandChanged = onBrandChanged
        self.onPurchaseUrlChanged = onPurchaseUrlChanged
        self.showCategoryError = showCategoryError
        self.showSeasonError = showSeasonError
        self.completedItemIndices = completedItemIndices
        self.onThumbnailTap = onThumbnailTap
        self.showTitle = showTitle
        self.showEditButton = showEditButton
        self.onEditButtonTap = onEditButtonTap
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
            // Title (조건부 표시)
            if showTitle {
                Text(title)
                    .font(.codive_title1)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .padding(.horizontal, 20)
            }

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
                mainImageContent(for: item, size: geometry.size.width)

                if showEditButton {
                    editButton
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func mainImageContent(for item: ClothingItem, size: CGFloat) -> some View {
        if let image = item.image {
            uiImageView(image, size: size)
        } else if let imageUrl = item.imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            asyncImageView(url: url, size: size)
        } else if let imageName = item.imageName, !imageName.isEmpty {
            assetImageView(imageName, size: size)
        } else {
            placeholderImageView(size: size)
        }
    }

    private func uiImageView(_ image: UIImage, size: CGFloat) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .frame(height: size)
            .background(Color.Codive.grayscale6)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func asyncImageView(url: URL, size: CGFloat) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.Codive.grayscale6)
                    .overlay(ProgressView())
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Rectangle()
                    .fill(Color.Codive.grayscale6)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(Color.Codive.grayscale4)
                    )
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: size)
        .background(Color.Codive.grayscale6)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func assetImageView(_ name: String, size: CGFloat) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .frame(height: size)
            .background(Color.Codive.grayscale6)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func placeholderImageView(size: CGFloat) -> some View {
        Rectangle()
            .fill(Color.Codive.grayscale6)
            .frame(maxWidth: .infinity)
            .frame(height: size)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var editButton: some View {
        Button {
            onEditButtonTap?()
        } label: {
            Image(systemName: "eraser")
                .font(.system(size: 16))
                .foregroundStyle(Color.Codive.grayscale2)
                .frame(width: 30, height: 30)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(12)
    }
    
    private var thumbnailImagesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    thumbnailButton(for: item, at: index)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func thumbnailButton(for item: ClothingItem, at index: Int) -> some View {
        Button {
            if let onThumbnailTap {
                onThumbnailTap(index)
            } else {
                withAnimation {
                    selectedItemIndex = index
                }
            }
        } label: {
            Group {
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if let imageUrl = item.imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Color.Codive.grayscale6
                        }
                    }
                } else if let imageName = item.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
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
            .overlay {
                if completedItemIndices.contains(index) && selectedItemIndex != index {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.Codive.grayscale5.opacity(0.6))
                }
            }
        }
    }
    
    // MARK: - Form Fields Section
    @ViewBuilder
    private func formFieldsSection(for item: ClothingItem) -> some View {
        VStack(spacing: 16) {
            CustomTextFieldButton(
                title: TextLiteral.Closet.category,
                value: item.category.isEmpty ? "" : "\(item.category) > \(item.subcategory)",
                placeholder: TextLiteral.Closet.categoryPlaceholder,
                showRequiredMark: true,
                showError: showCategoryError,
                action: onCategoryTap
            )

            CustomTextFieldButton(
                title: TextLiteral.Closet.season,
                value: item.season,
                placeholder: TextLiteral.Closet.seasonPlaceholder,
                showRequiredMark: true,
                showError: showSeasonError,
                action: onSeasonTap
            )

            CustomTextField1(
                title: TextLiteral.Closet.clothName,
                placeholder: TextLiteral.Closet.clothNamePlaceholder,
                text: Binding(
                    get: { item.name },
                    set: { onNameChanged?($0) }
                )
            )

            CustomTextField1(
                title: TextLiteral.Closet.brand,
                placeholder: TextLiteral.Closet.brandPlaceholder,
                text: Binding(
                    get: { item.brand },
                    set: { onBrandChanged?($0) }
                )
            )

            CustomTextField1(
                title: TextLiteral.Closet.purchaseUrl,
                placeholder: TextLiteral.Closet.purchaseUrlPlaceholder,
                text: Binding(
                    get: { item.purchaseUrl },
                    set: { onPurchaseUrlChanged?($0) }
                )
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

            Text(TextLiteral.Closet.noClothInfo)
                .font(.codive_body1_regular)
                .foregroundStyle(Color.Codive.grayscale3)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .padding(.top, 20)
    }
}
