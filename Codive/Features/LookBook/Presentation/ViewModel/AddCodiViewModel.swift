//
//  AddCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI

/// 코디 추가(AddCodiView) 화면에서 사용되는 ViewModel
/// - 역할:
///   - 코디 이름 / 메모 입력 상태 관리
///   - 신규 코디 생성 or 기존 코디 불러오기 분기 처리
///   - 조합 완료/성공 UI 상태 관리
///   - 하위 화면(AddCodiDetail / AddBeforeCodi)으로의 네비게이션 제어
@MainActor
final class AddCodiViewModel: ObservableObject {

    // MARK: - Dependencies

    /// 화면 전환(뒤로가기, 다음 화면 이동)을 담당하는 라우터
    private let navigationRouter: NavigationRouter

    /// LookBook / Codi 관련 비즈니스 로직을 담당하는 UseCase
    private let useCase: LookBookUseCase

    /// 현재 코디를 추가할 대상 룩북 ID
    let lookbookId: Int

    // MARK: - Published State (Codi Info)

    /// 코디 이름 입력값
    @Published var codiName: String = ""

    /// 코디 메모 입력값
    @Published var memo: String = ""

    /// 대표 이미지 URL
    /// - 이전 코디 불러오기 시 설정
    /// - 직접 조합한 경우 nil 상태 가능
    @Published var selectedImageURL: String?

    // MARK: - Published State (UI Control)

    /// 신규 조합 코디 여부
    /// - true: AddCodiDetailView에서 직접 조합
    /// - false: 이전 코디 불러오기
    @Published var isNewlyCombined: Bool = false

    /// 하단 선택 바텀시트 표시 여부
    @Published var isShowingBottomSheet: Bool = false

    /// 성공 화면 표시 여부
    @Published var isShowingSuccessView: Bool = false

    /// 성공 화면에 표시할 메시지
    @Published var successMessage: String = ""

    // MARK: - Published State (Combined Items)

    /// 직접 조합한 코디 아이템 목록
    /// AddCodiDetailView에서 전달받는다.
    @Published var combinedItems: [DraggableImageEntity] = []

    // MARK: - Initializer

    /// ViewModel 생성자
    /// - Parameters:
    ///   - navigationRouter: 화면 전환 담당 Router
    ///   - useCase: LookBook / Codi UseCase
    ///   - lookbookId: 코디를 추가할 룩북 ID
    ///   - selectedCodiData: 이전 코디 불러오기 / 상세 조합 결과 데이터
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase,
        lookbookId: Int,
        selectedCodiData: SelectedCodi? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.lookbookId = lookbookId

        // 이전 화면에서 코디 데이터를 전달받은 경우 초기 상태 설정
        if let data = selectedCodiData {
            self.selectedImageURL = data.imageURL
            self.codiName = data.name
            self.memo = data.memo
            self.combinedItems = data.combinedItems ?? []
            self.isNewlyCombined = true

            // 진입 경로에 따른 성공 메시지 설정
            if !self.combinedItems.isEmpty {
                // AddCodiDetailView에서 직접 조합한 경우
                self.successMessage = "옷코디를 완성했어요!"
            } else {
                // AddBeforeCodiView에서 기존 코디를 불러온 경우
                self.successMessage = "코디를 추가했어요!"
            }
        }
    }

    // MARK: - Computed Properties

    /// 완료 버튼 활성화 여부
    /// - 조건:
    ///   - 코디 이름이 비어있지 않아야 함
    ///   - 대표 이미지가 있거나, 직접 조합한 아이템이 존재해야 함
    var isButtonEnabled: Bool {
        let hasImage =
            (selectedImageURL != nil && !(selectedImageURL?.isEmpty ?? true)) ||
            !combinedItems.isEmpty

        return !codiName.isEmpty && hasImage
    }

    // MARK: - User Actions

    /// 상단 백 버튼 탭 처리
    func handleBackTap() {
        navigationRouter.navigateBack()
    }

    /// 코디 업로드 버튼 탭 처리
    /// 하단 바텀시트를 표시한다.
    func handleCodiUploadTap() {
        isShowingBottomSheet = true
    }

    /// 코디 추가 완료 처리
    /// - 성공 화면 표시
    /// - 일정 시간 후 자동으로 뒤로가기
    func handleCompleteTap() {
        // 성공 화면 표시
        isShowingSuccessView = true

        // 1.5초 후 성공 화면 종료 및 뒤로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isShowingSuccessView = false
            self.navigationRouter.navigateBack()
        }
    }

    // MARK: - Navigation (Bottom Sheet Actions)

    /// 신규 코디 조합 화면(AddCodiDetailView)으로 이동
    func navigateToNewCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addCodiDetail)
    }

    /// 이전 코디 불러오기 화면(AddBeforeCodiView)으로 이동
    func handleRecallCodi() {
        isShowingBottomSheet = false
        navigationRouter.navigate(to: .addBeforeCodi(lookbookId: lookbookId))
    }
}

// MARK: - Preview / Mock

extension AddCodiViewModel {

    /// SwiftUI Preview 및 테스트용 Mock ViewModel
    static var preview: AddCodiViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = LookBookDataSource()
        let mockRepository = LookBookRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = LookBookUseCase(repository: mockRepository)

        return AddCodiViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase,
            lookbookId: 1
        )
    }
}
