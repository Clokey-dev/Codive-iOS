//
//  ImageCropView.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI
import Mantis

// MARK: - ImageCropView
struct ImageCropView: UIViewControllerRepresentable {
    
    let image: UIImage
    let onComplete: (UIImage) -> Void
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> CropViewController {
        // 3:4 비율 설정
        var config = Mantis.Config()
        config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 3.0 / 4.0)
        config.cropViewConfig.cropShapeType = .rect
        
        let cropViewController = Mantis.cropViewController(
            image: image,
            config: config
        )
        cropViewController.delegate = context.coordinator
        
        return cropViewController
    }
    
    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, CropViewControllerDelegate {
        let parent: ImageCropView
        
        init(_ parent: ImageCropView) {
            self.parent = parent
        }
        
        func cropViewControllerDidCrop(
            _ cropViewController: CropViewController,
            cropped: UIImage,
            transformation: Transformation,
            cropInfo: CropInfo
        ) {
            parent.onComplete(cropped)
        }
        
        func cropViewControllerDidCancel(
            _ cropViewController: CropViewController,
            original: UIImage
        ) {
            parent.onCancel()
        }
    }
}
