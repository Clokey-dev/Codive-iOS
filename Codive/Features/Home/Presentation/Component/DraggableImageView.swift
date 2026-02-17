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
    let onActivate: (Int64) -> Void

    var body: some View {
        ZStack {
            ForEach($items) { $item in
                ZoomRotateDragView(
                    id: item.id,
                    position: $item.position,
                    scale: $item.scale,
                    rotation: $item.rotation,
                    onActivate: { onActivate(item.id) },
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
                    }
                )
            }
        }
    }
}
