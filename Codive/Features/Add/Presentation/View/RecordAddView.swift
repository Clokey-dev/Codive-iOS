//
//  RecordAddView.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

// MARK: - RecordAddView
struct RecordAddView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: RecordAddViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 4)
    private let cellSize: CGFloat = (UIScreen.main.bounds.width - 9) / 4 // 3px * 3 간격 / 4개
    
    // MARK: - Initializer
    init(viewModel: RecordAddViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            CustomNavigationBar(
                title: TextLiteral.Add.recordAddNavigationTitle,
                onBack: {
                    viewModel.dismissView()
                },
                rightButton: .text(
                    title: TextLiteral.Add.completeButtonTitle,
                    isEnabled: viewModel.isCompleteEnabled
                ) {
                    viewModel.completeSelection()
                }
            )
            
            // Album Selector
            Button(action: {
                viewModel.showAlbumSheet()
            }) {
                HStack(spacing: 4) {
                    Text(viewModel.selectedAlbumTitle)
                        .font(.codive_body1_medium)
                        .foregroundColor(.Codive.grayscale1)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.Codive.grayscale3)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Photo Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 3) {
                    // 첫 번째 셀: 카메라
                    CameraCell(
                        size: CGSize(width: cellSize, height: cellSize),
                        onTap: {
                            viewModel.showCamera()
                        }
                    )
                    
                    // 나머지 셀: 갤러리 사진들
                    ForEach(viewModel.photos) { photo in
                        PhotoGridCell(
                            asset: photo.asset,
                            isSelected: photo.isSelected,
                            selectionOrder: photo.selectionOrder,
                            size: CGSize(width: cellSize, height: cellSize)
                        )
                        .onTapGesture {
                            viewModel.togglePhotoSelection(photo)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .sheet(isPresented: $viewModel.isAlbumSheetPresented) {
            AlbumBottomSheet(
                albums: viewModel.albums,
                selectedAlbum: viewModel.selectedAlbum,
                onSelect: { album in
                    viewModel.selectAlbum(album)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(isPresented: $viewModel.isCameraPresented) {
            CameraView { image in
                viewModel.handleCameraCapture(image: image)
            }
            .ignoresSafeArea()
        }
        .task {
            await viewModel.requestAuthorization()
        }
        .onAppear {
            viewModel.resetSelection()
        }
    }
}

#Preview {
    let dataSource = PhotoDataSource()
    let repository = PhotoRepositoryImpl(dataSource: dataSource)
    let useCase = FetchPhotosUseCase(repository: repository)
    let router = NavigationRouter()
    let viewModel = RecordAddViewModel(
        fetchPhotosUseCase: useCase,
        navigationRouter: router
    )
    
    return RecordAddView(viewModel: viewModel)
}
