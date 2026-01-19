//
//  DraggableImageView.swift
//  Codive
//
//  Created by 한금준 on 11/11/25.
//

import SwiftUI

struct EditableImage: Identifiable {
    let id: UUID = UUID()
    let url: URL
}

// MARK: - ContentView
struct DraggableImageView: View {

    @State private var activeImageID: UUID?

    @State private var images: [EditableImage] = [
        EditableImage(url: URL(string: "https://picsum.photos/300")!),
        EditableImage(url: URL(string: "https://picsum.photos/250")!),
        EditableImage(url: URL(string: "https://picsum.photos/280")!)
    ]

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width - 16

            ZStack {
                ForEach(images) { image in
                    ZoomRotateDragView(
                        id: image.id,
                        activeID: $activeImageID,
                        onActivate: {
                            bringToFront(id: image.id)
                        }
                    ) {
                        AsyncImage(url: image.url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 180, height: 180)

                            case .success(let img):
                                img
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 180, height: 180)

                            case .failure:
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 180, height: 180)

                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    // MARK: - Layer Control
    private func bringToFront(id: UUID) {
        guard let index = images.firstIndex(where: { $0.id == id }) else { return }
        let selected = images.remove(at: index)
        images.append(selected)
    }
}
