//
//  AlbumBottomSheet.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI
import Photos

// MARK: - AlbumBottomSheet
struct AlbumBottomSheet: View {
    
    // MARK: - Properties
    let albums: [PhotoAlbum]
    let selectedAlbum: PhotoAlbum?
    let viewModel: RecordAddViewModel
    let onSelect: (PhotoAlbum) async -> Void
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle Bar
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(albums, id: \.id) { album in
                            AlbumRow(
                                album: album,
                                isSelected: selectedAlbum?.id == album.id,
                                viewModel: viewModel
                            ) {
                                await onSelect(album)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - AlbumRow
struct AlbumRow: View {
    
    // MARK: - Properties
    let album: PhotoAlbum
    let isSelected: Bool
    let viewModel: RecordAddViewModel
    let onTap: () async -> Void
    
    @State private var thumbnail: UIImage?
    
    // MARK: - Body
    var body: some View {
        Button {
            Task {
                await onTap()
            }
        } label: {
            HStack(spacing: 12) {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                }
                
                // 앨범 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(album.title)
                        .font(.codive_body1_medium)
                        .foregroundStyle(Color.Codive.grayscale1)
                    
                    Text("\(album.count)")
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale3)
                }
                
                Spacer()
                
                // 선택 체크
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.Codive.main0)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .task {
            await loadThumbnail()
        }
    }
    
    // MARK: - Methods
    private func loadThumbnail() async {
        guard let asset = album.thumbnail else { return }
        thumbnail = await viewModel.loadThumbnail(for: asset, size: CGSize(width: 120, height: 120))
    }
}
