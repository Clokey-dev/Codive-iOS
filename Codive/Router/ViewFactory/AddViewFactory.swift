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
        case .recordAdd(let selectedDate):
            makeRecordAddViewWithDate(selectedDate: selectedDate)
        case .clothPhotoSelect:
            addDIContainer?.makeRecordAddView(flowType: .cloth)
        case .clothAdd(let photos, let isAIEnabled):
            addDIContainer?.makeClothAddView(selectedPhotos: photos, isAIEnabled: isAIEnabled)
        case .photoEdit(let photos):
            addDIContainer?.makePhotoEditView(selectedPhotos: photos, flowType: .record)
        case .photoEditForCloth(let photos, let isAIEnabled):
            addDIContainer?.makePhotoEditView(selectedPhotos: photos, flowType: .cloth, isAIEnabled: isAIEnabled)
        case .recordDetail(let photos, let selectedDate):
            addDIContainer?.makeRecordDetailView(selectedPhotos: photos, selectedDate: selectedDate ?? addDIContainer?.selectedDate)
        case .recordEdit(let feed):
            addDIContainer?.makeRecordDetailViewForEdit(feed: feed)
        case .photoTag(let photo, let allPhotos):
            addDIContainer?.makePhotoTagView(photo: photo, allPhotos: allPhotos)
        case .eraserEditor(let photo, let photoIndex):
            addDIContainer?.makeEraserEditorView(photo: photo, photoIndex: photoIndex)
        case .eraserPreview(let photoIndex):
            addDIContainer?.makeEraserPreviewView(photoIndex: photoIndex)
        default:
            EmptyView()
        }
    }

    private func makeRecordAddViewWithDate(selectedDate: Date?) -> RecordAddView? {
        addDIContainer?.selectedDate = selectedDate
        return addDIContainer?.makeRecordAddView(flowType: .record)
    }
}
