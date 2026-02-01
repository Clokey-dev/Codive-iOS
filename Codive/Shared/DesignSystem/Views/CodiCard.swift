//
//  LookBookCard.swift
//  Codive
//
//  Created by 한태빈 on 1/15/26.
//

import SwiftUI

struct CodiCard: View {

    enum Icon {
        case heart(isSelected: Bool, onTap: (() -> Void)?)
        case checkmark(isSelected: Bool, onTap: (() -> Void)?)
        case none
    }

    let imageURL: URL?
    let title: String?
    let icon: Icon

    var cardWidth: CGFloat = 160
    var imageSize: CGFloat = 160
    var cornerRadius: CGFloat = 16
    var titleFont: Font = .system(size: 14, weight: .medium)
    var titleLineLimit: Int = 1
    var iconPadding: CGFloat = 12
    var iconSize: CGFloat = 20

    var onCardTap: (() -> Void)?

    init(
        imageURL: URL?,
        title: String? = nil,
        icon: Icon = .none,
        cardWidth: CGFloat = 160,
        imageSize: CGFloat = 160,
        cornerRadius: CGFloat = 16,
        titleFont: Font = .system(size: 14, weight: .medium),
        titleLineLimit: Int = 1,
        iconPadding: CGFloat = 12,
        iconSize: CGFloat = 20,
        onCardTap: (() -> Void)? = nil
    ) {
        self.imageURL = imageURL
        self.title = title
        self.icon = icon
        self.cardWidth = cardWidth
        self.imageSize = imageSize
        self.cornerRadius = cornerRadius
        self.titleFont = titleFont
        self.titleLineLimit = titleLineLimit
        self.iconPadding = iconPadding
        self.iconSize = iconSize
        self.onCardTap = onCardTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                imageView
                    .frame(width: imageSize, height: imageSize)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.Codive.grayscale7, lineWidth: 1)
                    }
                    .codiveCardShadow()

                iconOverlay
            }
            .frame(width: imageSize, height: imageSize)

            if let title {
                Text(title)
                    .font(titleFont)
                    .lineLimit(titleLineLimit)
            }
        }
        .frame(width: cardWidth, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { onCardTap?() }
    }

    private var imageView: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                Rectangle().fill(Color(.systemGray3))
            default:
                Rectangle().fill(Color(.systemGray5))
            }
        }
        .clipped()
    }

    @ViewBuilder
    private var iconOverlay: some View {
        switch icon {
        case .none:
            EmptyView()
        case .heart(let isSelected, let onTap):
            iconButton(imageName: isSelected ? "heart_on" : "heart_off", onTap: onTap)
        case .checkmark(let isSelected, let onTap):
            iconButton(imageName: isSelected ? "check_on" : "check_off", onTap: onTap)
        }
    }

    private func iconButton(imageName: String, onTap: (() -> Void)?) -> some View {
        Button { onTap?() } label: {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .padding(iconPadding)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
