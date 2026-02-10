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
            addDIContainer?.makeRecordAddView(flowType: .record)
        case .clothPhotoSelect:
            addDIContainer?.makeRecordAddView(flowType: .cloth)
        case .clothAdd(let photos):
            addDIContainer?.makeClothAddView(selectedPhotos: photos)
        case .photoEdit(let photos):
            addDIContainer?.makePhotoEditView(selectedPhotos: photos, flowType: .record)
        case .photoEditForCloth(let photos):
            addDIContainer?.makePhotoEditView(selectedPhotos: photos, flowType: .cloth)
        case .recordDetail(let photos):
            addDIContainer?.makeRecordDetailView(selectedPhotos: photos)
        case .recordEdit(let feed):
            addDIContainer?.makeRecordDetailViewForEdit(feed: feed)
        case .photoTag(let photo, let allPhotos):
            addDIContainer?.makePhotoTagView(photo: photo, allPhotos: allPhotos)
        default:
            EmptyView()
        }
    }
}
