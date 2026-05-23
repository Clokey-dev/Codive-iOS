//
//  DraggableImageView.swift
//  Codive
//
//  Created by 한금준 on 11/11/25.
//

import SwiftUI
import Kingfisher

struct DraggableImageView<T: DraggableImageProtocol>: View {
    @Binding var items: [T]
    let selectedImageID: Int64?
    let onActivate: (Int64) -> Void
    let onDeselect: () -> Void

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { onDeselect() }

            ForEach($items) { $item in
                ZoomRotateDragView(
                    id: item.id,
                    position: $item.position,
                    scale: $item.scale,
                    rotation: $item.rotation,
                    isSelected: item.id == selectedImageID,
                    onActivate: { onActivate(item.id) },
                    onTap: { onActivate(item.id) },
                    content: {
                        KFImage(URL(string: item.imageUrl))
                            .placeholder {
                                ProgressView()
                                    .frame(width: 180, height: 180)
                            }
                            .onFailure { _ in }
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                )
            }
        }
    }
}
