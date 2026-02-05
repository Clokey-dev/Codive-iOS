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
    
    @Published var isPastCodiSelected: Bool = false
    private var selectedTodayCoordinateId: Int64?
    
    private var cancellables = Set<AnyCancellable>()
    private let navigationRouter: NavigationRouter
    private let codiUseCase: CodiUseCase
    let lookBookId: Int64
    
    static let editCodiRequested = CurrentValueSubject<CodiEditData?, Never>(nil)
    static let beforeCodiSelected = PassthroughSubject<BeforeCoordinateDailyEntity, Never>()
    
    var isButtonEnabled: Bool {
        let hasImage = capturedImage != nil || (selectedImageURL != nil && !selectedImageURL!.isEmpty)
        return !codiName.isEmpty && hasImage
    }
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, codiUseCase: CodiUseCase, lookBookId: Int64) {
        self.navigationRouter = navigationRouter
        self.codiUseCase = codiUseCase
        self.lookBookId = lookBookId
        
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
                self?.isPastCodiSelected = false
                self?.selectedTodayCoordinateId = nil
            }
            .store(in: &cancellables)
        
        AddCodiViewModel.beforeCodiSelected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entity in
                self?.selectedImageURL = entity.imageUrl
                self?.selectedTodayCoordinateId = entity.id
                self?.isPastCodiSelected = true
                self?.capturedImage = nil
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
        if isPastCodiSelected {
            createAutoCoordinate()
        } else {
            createManualCoordinate()
        }
    }

    /// [추가] 과거 코디를 이용한 자동 생성 로직
    private func createAutoCoordinate() {
        guard let dailyId = selectedTodayCoordinateId else { return }
        
        let request = CreateAutoDailyCoordinateAPIRequestDTO(
            name: codiName,
            memo: memo,
            dailyCoordinateId: dailyId,
            lookBookId: lookBookId
        )
        
        Task {
            do {
                _ = try await codiUseCase.createAutoDailyCoordinate(request: request)
                processSuccess()
            } catch {
                print("❌ 자동 코디 생성 실패: \(error.localizedDescription)")
            }
        }
    }

    /// [기존 로직 분리] 수동 생성 로직
    private func createManualCoordinate() {
        guard isButtonEnabled, let imageURL = selectedImageURL else {
            return
        }
        
        let requestDTO = CreateManualCoordinateAPIRequestDTO(
            coordinateImageUrl: imageURL,
            name: codiName,
            memo: memo,
            lookBookId: lookBookId,
            payloads: receivedPayloads
        )
        
        Task {
            do {
                _ = try await codiUseCase.createManualCoordinate(request: requestDTO)
                processSuccess()
            } catch {
                print("❌ 수동 코디 생성 실패: \(error.localizedDescription)")
            }
        }
    }

    /// 성공 공통 처리
    private func processSuccess() {
        self.successMessage = TextLiteral.LookBook.alertSuccessPostCoordi
        self.isShowingSuccessView = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            self.isShowingSuccessView = false
            self.navigationRouter.navigateBack()
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
        self.isPastCodiSelected = false
    }
    
    func handleRecallCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addBeforeCodi(lookbookId: lookBookId))
    }
}
