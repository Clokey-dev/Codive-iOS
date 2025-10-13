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
    @Environment(\.dismiss) private var dismiss
    
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
                title: "기록 추가",
                onBack: {
                    dismiss()
                },
                rightButton: .text(
                    title: "완료",
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
        .task {
            await viewModel.requestAuthorization()
        }
    }
}

#Preview {
    let dataSource = PhotoDataSource()
    let repository = PhotoRepositoryImpl(dataSource: dataSource)
    let useCase = FetchPhotosUseCase(repository: repository)
    let viewModel = RecordAddViewModel(fetchPhotosUseCase: useCase)
    
    return RecordAddView(viewModel: viewModel)
}
