//
//  PhotoGridCell.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI
import Photos

// MARK: - PhotoGridCell
struct PhotoGridCell: View {
    
    // MARK: - Properties
    let asset: PHAsset
    let isSelected: Bool
    let selectionOrder: Int?
    let size: CGSize
    let viewModel: RecordAddViewModel
    
    @State private var image: UIImage?
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.gray.opacity(0.2)
                .frame(width: size.width, height: size.height)
            
            // 사진 (로드되면 fade-in)
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .transition(.opacity)
            }
            
            // 선택 표시
            if let order = selectionOrder, isSelected {
                Circle()
                    .fill(Color.Codive.main0)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("\(order)")
                            .font(.codive_body3_medium)
                            .foregroundStyle(.white)
                    )
                    .padding(8)
            } else {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.Codive.main0 : Color.black.opacity(0.3))
                    )
                    .frame(width: 24, height: 24)
                    .padding(8)
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .task {
            await loadImage()
        }
    }
    
    // MARK: - Methods
    private func loadImage() async {
        let scale = UIScreen.main.scale
        let thumbnailSize = CGSize(width: size.width * scale, height: size.height * scale)
        image = await viewModel.loadThumbnail(for: asset, size: thumbnailSize)
        
        if image != nil {
            withAnimation(.easeOut(duration: 0.2)) {
            }
        }
    }
}
