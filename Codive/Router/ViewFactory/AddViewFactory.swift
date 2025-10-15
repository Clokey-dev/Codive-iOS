//
//  AddViewFactory.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

@MainActor
final class AddViewFactory {
    
    // MARK: - Properties
    private weak var addDIContainer: AddDIContainer? 
    
    // MARK: - Initializer
    init(addDIContainer: AddDIContainer) {
        self.addDIContainer = addDIContainer
    }
    
    // MARK: - Methods
    @ViewBuilder
    func makeView(for destination: AppDestination) -> some View {
        switch destination {
        case .recordAdd:
            addDIContainer?.makeRecordAddView()
        case .photoEdit(let photos):
            PhotoEditView(
                viewModel: PhotoEditViewModel(
                    selectedPhotos: photos,
                    navigationRouter: addDIContainer?.navigationRouter ?? NavigationRouter()
                )
            )
        case .recordDetail(let photos):
            addDIContainer?.makeRecordDetailView(selectedPhotos: photos)
        case .photoTag(let photo, let allPhotos):
            addDIContainer?.makePhotoTagView(photo: photo, allPhotos: allPhotos)
        default:
            EmptyView()
        }
    }
}
