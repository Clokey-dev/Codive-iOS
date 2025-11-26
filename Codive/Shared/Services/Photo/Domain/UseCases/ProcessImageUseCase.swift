//
//  ProcessImageUseCase.swift
//  Codive
//
//  Created by 황상환 on 10/15/25.
//

import UIKit

// TODO: - 나중에 Utils/Helper로 구분
final class ProcessImageUseCase {
    
    // MARK: - Crop Image
    
    /// 이미지를 3:4 비율로 크롭합니다
    /// - Parameter image: 원본 이미지
    /// - Returns: 크롭된 이미지
    func cropTo3_4Ratio(_ image: UIImage) -> UIImage {
        return cropToRatio(image, ratio: 3.0 / 4.0)
    }

    /// 이미지를 1:1 비율로 크롭합니다
    /// - Parameter image: 원본 이미지
    /// - Returns: 크롭된 이미지
    func cropTo1_1Ratio(_ image: UIImage) -> UIImage {
        return cropToRatio(image, ratio: 1.0)
    }

    /// 이미지를 지정된 비율로 크롭합니다
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - ratio: 목표 비율 (width / height)
    /// - Returns: 크롭된 이미지
    private func cropToRatio(_ image: UIImage, ratio: CGFloat) -> UIImage {
        let imageSize = image.size
        let currentRatio = imageSize.width / imageSize.height

        var cropRect: CGRect

        if currentRatio > ratio {
            // 이미지가 더 넓음 - 너비를 자름
            let targetWidth = imageSize.height * ratio
            let x = (imageSize.width - targetWidth) / 2
            cropRect = CGRect(x: x, y: 0, width: targetWidth, height: imageSize.height)
        } else {
            // 이미지가 더 높음 - 높이를 자름
            let targetHeight = imageSize.width / ratio
            let y = (imageSize.height - targetHeight) / 2
            cropRect = CGRect(x: 0, y: y, width: imageSize.width, height: targetHeight)
        }

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // MARK: - Resize Image
    
    /// 메모리 최적화를 위해 이미지를 리사이징합니다
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - maxSize: 최대 크기 (width 또는 height)
    /// - Returns: 리사이징된 이미지
    func resizeImage(_ image: UIImage, maxSize: CGSize) -> UIImage {
        let size = image.size
        
        // 이미 작으면 그대로 반환
        if size.width <= maxSize.width && size.height <= maxSize.height {
            return image
        }
        
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// 이미지를 최적화합니다 (크롭 + 리사이징)
    /// - Parameter image: 원본 이미지
    /// - Returns: 3:4 비율로 크롭되고 최적화된 이미지
    func optimizeImageForRecord(_ image: UIImage) -> UIImage {
        // 1. 먼저 크롭
        let croppedImage = cropTo3_4Ratio(image)
        
        // 2. 너무 크면 리사이징 (최대 2000x2000)
        let maxSize = CGSize(width: 2000, height: 2000)
        return resizeImage(croppedImage, maxSize: maxSize)
    }
}
