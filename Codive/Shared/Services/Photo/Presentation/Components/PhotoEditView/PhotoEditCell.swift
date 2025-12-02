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
    
    // MARK: - Body
    var body: some View {
        // 썸네일 이미지
        Image(uiImage: photo.croppedImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 80)
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
