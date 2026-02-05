//
//  AddCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI
import Combine

@MainActor
final class AddCodiViewModel: ObservableObject {
    
    // MARK: - Properties (State)
    @Published var codiName: String = ""
    @Published var memo: String = ""
    
    @Published var selectedImageURL: String?
    @Published var capturedImage: UIImage?
    @Published var capturedImageBase64: String?
    @Published var combinedItems: [DraggableImageEntity] = []
    @Published var receivedPayloads: [Payloads] = []
    @Published var isNewlyCombined: Bool = false
    @Published var isShowingBottomSheet: Bool = false
    @Published var isShowingSuccessView: Bool = false
    @Published var successMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let navigationRouter: NavigationRouter
    private let codiUseCase: CodiUseCase
    let coordinateId: Int64
    
    static let editCodiRequested = CurrentValueSubject<CodiEditData?, Never>(nil)
    static let beforeCodiSelected = PassthroughSubject<BeforeCoordinateDailyEntity, Never>()
    
    var isButtonEnabled: Bool {
        let hasImage = capturedImage != nil || (selectedImageURL != nil && !selectedImageURL!.isEmpty)
        return !codiName.isEmpty && hasImage
    }
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, codiUseCase: CodiUseCase, coordinateId: Int64) {
        self.navigationRouter = navigationRouter
        self.codiUseCase = codiUseCase
        self.coordinateId = coordinateId
        
        setupDataSubscription()
    }
}

private extension AddCodiViewModel {
    func setupDataSubscription() {
        cancellables.removeAll()
        
        AddCodiDetailViewModel.codiDataUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.receivedPayloads = data.payloads
                self?.selectedImageURL = data.imageString
            }
            .store(in: &cancellables)
        
        AddCodiViewModel.beforeCodiSelected
                .receive(on: DispatchQueue.main)
                .sink { [weak self] entity in
                    // 선택된 코디의 이미지를 미리보기에 반영
                    self?.selectedImageURL = entity.imageUrl
                    // 필요하다면 기본 이름을 설정해줄 수도 있습니다.
                    // self?.codiName = "과거 코디 (\(entity.date))"
                }
                .store(in: &cancellables)
    }
}

extension AddCodiViewModel {
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func handleCodiUploadTap() {
        isShowingBottomSheet = true
    }
    
    func handleCompleteTap() {
        guard isButtonEnabled, let imageURL = selectedImageURL else {
            return
        }
        
        let requestDTO = CreateManualCoordinateAPIRequestDTO(
            coordinateImageUrl: imageURL,
            name: codiName,
            memo: memo,
            lookBookId: Int64(coordinateId),
            payloads: receivedPayloads
        )
        
        Task {
            do {
                _ = try await codiUseCase.createManualCoordinate(request: requestDTO)
                
                self.successMessage = TextLiteral.LookBook.alertSuccessPostCoordi
                self.isShowingSuccessView = true
                
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                self.isShowingSuccessView = false
                self.navigationRouter.navigateBack()
            } catch {
                print("❌ 상세 에러 메시지: \(error.localizedDescription)")
            }
        }
    }
    
    func handleEditCodiTap() {
        guard let imageURL = selectedImageURL else {
            return
        }
        
        let editData = CodiEditData(
            payloads: receivedPayloads,
            imageURL: imageURL,
            codiName: codiName,
            memo: memo
        )
        
        Self.editCodiRequested.value = editData
        navigationRouter.navigate(to: .addCodiDetail)
    }
    
    func navigateToNewCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addCodiDetail)
    }
    
    func handleRecallCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addBeforeCodi(lookbookId: coordinateId))
    }
}
