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
        VStack(spacing: 0) {
            // Navigation Bar
            CustomNavigationBar(
                title: "사진 편집",
                onBack: {
                    viewModel.dismissView()
                },
                rightButton: .text(
                    title: "완료",
                    isEnabled: true
                ) {
                    viewModel.completeEditing()
                }
            )
            
            // Main Image Area
            ZStack(alignment: .topTrailing) {
                if let currentPhoto = viewModel.currentPhoto {
                    Image(uiImage: currentPhoto.croppedImage)
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                } else {
                    Color.gray.opacity(0.2)
                        .aspectRatio(3/4, contentMode: .fit)
                }
                
                // Crop Button
                Button(action: {
                    viewModel.startEditing()
                }) {
                    Image("crop_icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(16)
            }
            
            Spacer()
            
            // Bottom Controls
            VStack(spacing: 16) {
                // Photo Navigation
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.moveToPrevious()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(viewModel.canMoveBack ? .Codive.grayscale1 : .Codive.grayscale3)
                    }
                    .disabled(!viewModel.canMoveBack)
                    
                    Text("\(viewModel.currentIndex + 1) / \(viewModel.selectedPhotos.count)")
                        .font(.codive_body1_medium)
                        .foregroundColor(.Codive.grayscale1)
                    
                    Button(action: {
                        viewModel.moveToNext()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(viewModel.canMoveForward ? .Codive.grayscale1 : .Codive.grayscale3)
                    }
                    .disabled(!viewModel.canMoveForward)
                }
                .padding(.bottom, 8)
                
                // Photo Thumbnails
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.selectedPhotos) { photo in
                            PhotoEditCell(
                                photo: photo,
                                isSelected: photo.id == viewModel.currentPhoto?.id
                            )
                            .onTapGesture {
                                if let index = viewModel.selectedPhotos.firstIndex(where: { $0.id == photo.id }) {
                                    viewModel.currentIndex = index
                                }
                            }
                            .onDrag {
                                self.draggedPhoto = photo
                                return NSItemProvider(object: photo.id as NSString)
                            }
                            .onDrop(of: [.text], delegate: PhotoDropDelegate(
                                photo: photo,
                                photos: $viewModel.selectedPhotos,
                                draggedPhoto: $draggedPhoto,
                                onReorder: { source, destination in
                                    viewModel.reorderPhotos(from: source, to: destination)
                                }
                            ))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 100)
            }
            .padding(.bottom, 20)
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .sheet(isPresented: $viewModel.isEditingMode) {
            if let currentPhoto = viewModel.currentPhoto {
                ImageCropView(
                    image: currentPhoto.originalImage,
                    onComplete: { croppedImage in
                        viewModel.updateCroppedImage(croppedImage)
                    },
                    onCancel: {
                        viewModel.cancelEditing()
                    }
                )
            }
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

#Preview {
    let sampleImage = UIImage(systemName: "photo")!
    let photos = [
        SelectedPhoto(id: "1", originalImage: sampleImage, order: 1),
        SelectedPhoto(id: "2", originalImage: sampleImage, order: 2),
        SelectedPhoto(id: "3", originalImage: sampleImage, order: 3)
    ]
    let router = NavigationRouter()
    let viewModel = PhotoEditViewModel(selectedPhotos: photos, navigationRouter: router)
    
    return PhotoEditView(viewModel: viewModel)
}
