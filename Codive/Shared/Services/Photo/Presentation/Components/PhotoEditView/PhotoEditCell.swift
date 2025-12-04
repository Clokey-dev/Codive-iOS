//
//  PhotoEditCell.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

// MARK: - PhotoEditCell
struct PhotoEditCell: View {

    // MARK: - Properties
    let photo: SelectedPhoto
    let isSelected: Bool
    let aspectRatio: CGFloat

    // MARK: - Computed Properties
    private var thumbnailSize: CGSize {
        switch aspectRatio {
        case 1.0:  // 옷 추가 (1:1)
            return CGSize(width: 80, height: 80)
        default:  // 기록 추가 (3:4)
            return CGSize(width: 60, height: 80)
        }
    }

    // MARK: - Body
    var body: some View {
        // 썸네일 이미지
        Image(uiImage: photo.croppedImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isSelected ? Color.Codive.main0 : Color.clear,
                        lineWidth: 2
                    )
            )
    }
}
