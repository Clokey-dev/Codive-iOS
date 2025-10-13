//
//  PhotoAlbum.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import Photos

// MARK: - PhotoAlbum Entity
struct PhotoAlbum {
    let id: String
    let title: String
    let count: Int
    let collection: PHAssetCollection
    let thumbnail: PHAsset?
}

// MARK: - PhotoAsset Entity
struct PhotoAsset: Identifiable {
    let id: String
    let asset: PHAsset
    var isSelected: Bool = false
    var selectionOrder: Int?
}

// MARK: - SelectedPhoto Entity
struct SelectedPhoto: Identifiable, Equatable {
    let id: String
    let originalImage: UIImage
    var croppedImage: UIImage
    var order: Int
    
    init(id: String, originalImage: UIImage, order: Int) {
        self.id = id
        self.originalImage = originalImage
        self.croppedImage = Self.cropTo3_4Ratio(image: originalImage)
        self.order = order
    }
    
    // 3:4 비율로 자동 크롭
    private static func cropTo3_4Ratio(image: UIImage) -> UIImage {
        let targetRatio: CGFloat = 3.0 / 4.0
        let imageSize = image.size
        let currentRatio = imageSize.width / imageSize.height
        
        var cropRect: CGRect
        
        if currentRatio > targetRatio {
            // 이미지가 더 넓음 - 너비를 자름
            let targetWidth = imageSize.height * targetRatio
            let x = (imageSize.width - targetWidth) / 2
            cropRect = CGRect(x: x, y: 0, width: targetWidth, height: imageSize.height)
        } else {
            // 이미지가 더 높음 - 높이를 자름
            let targetHeight = imageSize.width / targetRatio
            let y = (imageSize.height - targetHeight) / 2
            cropRect = CGRect(x: 0, y: y, width: imageSize.width, height: targetHeight)
        }
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
