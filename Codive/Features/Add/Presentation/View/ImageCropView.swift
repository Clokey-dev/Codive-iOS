//
//  ImageCropView.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI
import SwiftyCrop

struct ImageCropView: View {
    
    // MARK: - Properties
    let image: UIImage
    let onComplete: (UIImage) -> Void
    let onCancel: () -> Void
    
    // MARK: - Body
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let maskHeight = (screenWidth - 40) * (4/3)
        
        SwiftyCropView(
            imageToCrop: image,
            maskShape: .rectangle,
            configuration: SwiftyCropConfiguration(
                maxMagnificationScale: 30.0,
                maskRadius: maskHeight / 2,
                cropImageCircular: false,
                rotateImage: false,
                zoomSensitivity: 5.0,
                rectAspectRatio: 3/4
            )
        ) { croppedImage in
            if let croppedImage = croppedImage {
                onComplete(croppedImage)
            } else {
                onCancel()
            }
        }
    }
}
