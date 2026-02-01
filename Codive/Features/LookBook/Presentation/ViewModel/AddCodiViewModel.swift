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
    
    // 초기 상태는 모두 nil/비어있음으로 설정하여 플레이스홀더가 나오게 함
    @Published var selectedImageURL: String? = nil
    @Published var capturedImage: UIImage? = nil
    @Published var capturedImageBase64: String? = nil
    @Published var combinedItems: [DraggableImageEntity] = []
    
    // 서버 전송용 데이터
    @Published var receivedPayloads: [Payloads] = []
    
    // UI 제어 상태
    @Published var isNewlyCombined: Bool = false
    @Published var isShowingBottomSheet: Bool = false
    @Published var isShowingSuccessView: Bool = false
    @Published var successMessage: String = ""
    
    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    private let navigationRouter: NavigationRouter
    private let codiUseCase: CodiUseCase
    let coordinateId: Int64
    
    // MARK: - Computed Properties
    var isButtonEnabled: Bool {
        let hasImage = capturedImage != nil || (selectedImageURL != nil && !selectedImageURL!.isEmpty)
        return !codiName.isEmpty && hasImage
    }
    
    // MARK: - Initializer
    init(navigationRouter: NavigationRouter, codiUseCase: CodiUseCase, coordinateId: Int64) {
        self.navigationRouter = navigationRouter
        self.codiUseCase = codiUseCase
        self.coordinateId = coordinateId
        
        // 데이터 수신 구독 설정
        setupDataSubscription()
    }
}

// MARK: - Setup Subscription
private extension AddCodiViewModel {
    func setupDataSubscription() {
        cancellables.removeAll()
        
        AddCodiDetailViewModel.codiDataUpdated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.receivedPayloads = data.payloads
                
                // ✅ 수정: imageString이 이제 URL이므로 selectedImageURL에 저장
                self?.selectedImageURL = data.imageString
                
                print("--- 📥 AddCodiView 데이터 수신 완료 ---")
                print("📍 받은 이미지 URL: \(data.imageString)")
                print("📍 Payloads 개수: \(data.payloads.count)")
            }
            .store(in: &cancellables)
    }
}

// MARK: - User Actions
extension AddCodiViewModel {
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
    
    func handleCodiUploadTap() {
        isShowingBottomSheet = true
    }
    
    func handleCompleteTap() {
        guard isButtonEnabled, let imageURL = selectedImageURL else {
            print("⚠️ [DEBUG] 전송 중단: 필수 데이터(이미지 또는 코디명) 누락")
            return
        }
        
        let requestDTO = CreateManualCoordinateAPIRequestDTO(
            coordinateImageUrl: imageURL,
            name: codiName,
            memo: memo,
            lookBookId: Int64(coordinateId),
            payloads: receivedPayloads
        )
        
        print("\n--- 🚀 [DEBUG] 서버 전송 요청 데이터 분석 시작 ---")
        print("📍 LookBook ID: \(requestDTO.lookBookId)")
        print("📍 Codi Name: \(requestDTO.name) (길이: \(requestDTO.name.count))")
        print("📍 Memo: \(requestDTO.memo)")
        print("📍 Image URL: \(requestDTO.coordinateImageUrl)")
        print("📍 Payloads 개수: \(requestDTO.payloads.count)")
        
        // Payloads 배열의 각 요소 상세 출력
        for (index, payload) in requestDTO.payloads.enumerated() {
            print("""
            [Payload #\(index + 1)]
            - clothId: \(payload.clothId)
            - location (X, Y): (\(payload.locationX), \(payload.locationY))
            - ratio: \(payload.ratio)
            - degree: \(payload.degree)
            - order: \(payload.order)
            """)
        }
        print("--- 🚀 [DEBUG] 데이터 분석 종료 ---\n")
        
        Task {
            do {
                _ = try await codiUseCase.createManualCoordinate(request: requestDTO)
                
                // ✅ 성공 로직 추가
                self.successMessage = "코디가 성공적으로 등록되었습니다."
                self.isShowingSuccessView = true
                
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                self.isShowingSuccessView = false
                self.navigationRouter.navigateBack()
            } catch {
                // 에러 발생 시 더 자세한 정보 출력
                print("❌ [DEBUG] 최종 생성 실패 - 에러 타입: \(type(of: error))")
                print("❌ [DEBUG] 상세 에러 메시지: \(error.localizedDescription)")
                if let apiError = error as? LookBookAPIError {
                    print("❌ [DEBUG] API 특정 에러: \(apiError)")
                }
            }
        }
    }
    
    func navigateToNewCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addCodiDetail(lookbookId: coordinateId))
    }
    
    func handleRecallCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addBeforeCodi(lookbookId: coordinateId))
    }
}
