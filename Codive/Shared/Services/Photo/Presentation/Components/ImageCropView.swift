//
//  ImageCropView.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

struct ImageCropView: View {

    // MARK: - Properties
    let image: UIImage
    let aspectRatio: CGFloat
    let onComplete: (UIImage) -> Void
    let onCancel: () -> Void

    // MARK: - Body
    var body: some View {
        CustomCropView(
            image: image,
            aspectRatio: aspectRatio,
            onComplete: onComplete
        )
    }
}
