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
                    onActivate: { onActivate(item.id) }
                ) {
                    // 순서 중요: KFImage 바로 뒤에 Kingfisher 전용 메서드를 배치합니다.
                    KFImage(URL(string: item.imageUrl))
                        .placeholder { // 로딩 중 보여줄 뷰
                            ProgressView()
                                .frame(width: 180, height: 180)
                        }
                        .onFailure { error in // 로드 실패 시 로직
                            print("이미지 로드 실패: \(error.localizedDescription)")
                        }
                        .resizable() // 여기서부터는 일반 SwiftUI View로 변환됨
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                }
            }
        }
    }
}
