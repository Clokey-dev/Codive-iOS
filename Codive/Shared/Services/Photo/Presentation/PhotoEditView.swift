//
//  PhotoEditView.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

// MARK: - PhotoEditView
struct PhotoEditView: View {

    // MARK: - Properties
    @StateObject private var viewModel: PhotoEditViewModel
    @State private var draggedPhoto: SelectedPhoto?

    // MARK: - Initializer
    init(viewModel: PhotoEditViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Main Content
            VStack(spacing: 0) {
                // Navigation Bar
                CustomNavigationBar(
                    title: TextLiteral.Add.photoEditTitle
                ) {
                    viewModel.dismissView()
                }

                // Photo Thumbnails (상단 미리보기)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.selectedPhotos.enumerated()), id: \.element.id) { index, photo in
                            PhotoEditCell(
                                photo: viewModel.selectedPhotos[index],
                                isSelected: index == viewModel.currentIndex,
                                aspectRatio: viewModel.aspectRatio
                            )
                            .id("\(photo.id)-\(photo.croppedImage.hashValue)")
                            .onTapGesture {
                                viewModel.currentIndex = index
                            }
                            .onDrag {
                                self.draggedPhoto = photo
                                return NSItemProvider(object: photo.id as NSString)
                            }
                            // swiftlint:disable trailing_closure
                            .onDrop(
                                of: [.text],
                                delegate: PhotoDropDelegate(
                                    photo: photo,
                                    photos: $viewModel.selectedPhotos,
                                    draggedPhoto: $draggedPhoto,
                                    onReorder: { source, destination in
                                        viewModel.reorderPhotos(from: source, to: destination)
                                    }
                                )
                            )
                            // swiftlint:enable trailing_closure
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 100)
                .padding(.top, 16)

                // Main Image Area (큰 이미지)
                ZStack(alignment: .topTrailing) {
                    if let currentPhoto = viewModel.currentPhoto {
                        Image(uiImage: currentPhoto.croppedImage)
                            .resizable()
                            .aspectRatio(viewModel.aspectRatio, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        Color.gray.opacity(0.2)
                            .aspectRatio(viewModel.aspectRatio, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Crop Button
                    Button {
                        viewModel.startEditing()
                    } label: {
                        Image("crop_icon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Bottom Button
                CustomButton(
                    text: TextLiteral.Add.photoEditComplete,
                    widthType: .fixed
                ) {
                    viewModel.completeEditing()
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 20)
            }

            // Crop Overlay (인라인, fullScreenCover 제거)
            if viewModel.isEditingMode, let currentPhoto = viewModel.currentPhoto {
                CustomCropView(
                    image: currentPhoto.originalImage ?? currentPhoto.croppedImage,
                    aspectRatio: viewModel.aspectRatio,
                    allowZoomOut: viewModel.allowZoomOut,
                    onComplete: { croppedImage in
                        viewModel.updateCroppedImage(croppedImage)
                        viewModel.isEditingMode = false
                    },
                    onCancel: {
                        viewModel.isEditingMode = false
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .alert(TextLiteral.Add.exitAlertTitle, isPresented: $viewModel.showExitAlert) {
            Button(TextLiteral.Add.exitAlertLeave, role: .destructive) {
                viewModel.confirmExit()
            }
        }
    }

    // MARK: - PhotoDropDelegate
    struct PhotoDropDelegate: DropDelegate {
        let photo: SelectedPhoto
        @Binding var photos: [SelectedPhoto]
        @Binding var draggedPhoto: SelectedPhoto?
        let onReorder: (IndexSet, Int) -> Void

        func performDrop(info: DropInfo) -> Bool {
            draggedPhoto = nil
            return true
        }

        func dropEntered(info: DropInfo) {
            guard let draggedPhoto = draggedPhoto,
                  draggedPhoto.id != photo.id,
                  let fromIndex = photos.firstIndex(where: { $0.id == draggedPhoto.id }),
                  let toIndex = photos.firstIndex(where: { $0.id == photo.id }) else {
                return
            }

            withAnimation(.spring()) {
                onReorder(IndexSet(integer: fromIndex), toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }
}
