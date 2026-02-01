//
//  DraggableImageView.swift
//  Codive
//
//  Created by 한금준 on 11/11/25.
//

import SwiftUI

struct DraggableImageView<T: DraggableImageProtocol>: View {
    @Binding var items: [T]
    let onActivate: (Int) -> Void

    var body: some View {
        ZStack {
            ForEach($items) { $item in
                ZoomRotateDragView(
                    id: item.id,
                    position: $item.position,
                    scale: $item.scale,
                    rotation: $item.rotation,
                    onActivate: { onActivate(item.id) }
                ) {
                    // 외부에서 이미지 렌더링 방식을 결정할 수도 있지만,
                    // 기본적으로 프로토콜의 imageUrl을 사용합니다.
                    AsyncImage(url: URL(string: item.imageUrl)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit()
                        } else {
                            Color.gray.opacity(0.2)
                                .overlay(ProgressView())
                        }
                    }
                    .frame(width: 180, height: 180)
                }
            }
        }
    }
}
