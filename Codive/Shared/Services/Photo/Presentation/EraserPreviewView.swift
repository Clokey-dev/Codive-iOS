//
//  EraserPreviewView.swift
//  Codive
//
//  Created by 황상환 on 2/22/26.
//

import SwiftUI

// MARK: - EraserPreviewView
struct EraserPreviewView: View {

    // MARK: - Properties
    let previewImage: UIImage
    let photoIndex: Int
    let navigationRouter: NavigationRouter
    @ObservedObject var clothAddViewModel: ClothAddViewModel

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "미리보기",
                onBack: {
                    navigationRouter.navigateBack()
                },
                rightButton: .text(
                    title: "완료",
                    isEnabled: true
                ) {
                    _ = navigationRouter.popTo { destination in
                        if case .clothAdd = destination { return true }
                        return false
                    }
                    DispatchQueue.main.async {
                        clothAddViewModel.updateErasedImage(at: photoIndex, image: previewImage)
                    }
                }
            )

            Spacer()

            Image(uiImage: previewImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(Color.Codive.grayscale6)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)

            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.white)
    }
}
