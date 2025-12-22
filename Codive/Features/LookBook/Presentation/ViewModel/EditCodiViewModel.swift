//
//  EditCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

/// 코디 수정(EditCodiView) 화면에서 사용되는 ViewModel
/// - 역할:
///   - 기존 코디 데이터 로드 및 수정 상태 관리
///   - 수정 여부(hasChanges) 판단
///   - 수정 완료 처리 및 네비게이션 제어
@MainActor
final class EditCodiViewModel: ObservableObject {

    // MARK: - Dependencies

    /// 화면 전환(뒤로가기 등)을 담당하는 라우터
    private let navigationRouter: NavigationRouter

    /// LookBook / Codi 관련 비즈니스 로직을 담당하는 UseCase
    private let useCase: LookBookUseCase

    /// 현재 코디가 속한 룩북 ID
    let lookbookId: Int

    /// 수정 중인 코디 ID
    /// 신규 코디가 아닌 경우에만 값이 존재한다.
    let codiId: Int?

    // MARK: - Original Data (Change Detection)

    /// 최초 로드된 코디 이름
    /// 수정 여부 판단을 위한 기준값
    private var originalName: String = ""

    /// 최초 로드된 코디 메모
    /// 수정 여부 판단을 위한 기준값
    private var originalMemo: String = ""

    // MARK: - Published State (Editable Fields)

    /// 코디 이름 입력값
    @Published var codiName: String = ""

    /// 코디 메모 입력값
    @Published var memo: String = ""

    /// 코디 대표 이미지 URL
    /// 수정 화면에서는 표시용으로만 사용
    @Published var selectedImageURL: String?

    // MARK: - Computed Properties

    /// 기존 데이터 대비 수정 사항이 있는지 여부
    /// 이름 또는 메모 중 하나라도 변경되면 true
    var hasChanges: Bool {
        return codiName != originalName || memo != originalMemo
    }

    /// 완료 버튼 활성화 여부
    /// - 코디 이름이 비어있지 않아야 함
    /// - 수정 사항이 존재해야 함
    var isButtonEnabled: Bool {
        !codiName.isEmpty && hasChanges
    }

    // MARK: - Initializer

    /// ViewModel 생성자
    /// - Parameters:
    ///   - navigationRouter: 화면 전환 담당 Router
    ///   - useCase: LookBook / Codi UseCase
    ///   - lookbookId: 코디가 속한 룩북 ID
    ///   - selectedCodiData: 수정할 기존 코디 데이터
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase,
        lookbookId: Int,
        selectedCodiData: SelectedCodi? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.lookbookId = lookbookId
        self.codiId = selectedCodiData?.codiId

        // 기존 코디 데이터가 전달된 경우 초기 상태 세팅
        if let data = selectedCodiData {
            self.selectedImageURL = data.imageURL
            self.codiName = data.name
            self.memo = data.memo

            // 변경 감지를 위한 원본 값 저장
            self.originalName = data.name
            self.originalMemo = data.memo
        }
    }

    // MARK: - User Actions

    /// 상단 백 버튼 탭 처리
    func handleBackTap() {
        navigationRouter.navigateBack()
    }

    /// 수정 완료 버튼 탭 처리
    /// 수정 사항이 있을 때만 동작한다.
    func handleCompleteTap() {
        guard hasChanges else { return }

        // TODO: API 연동 시 수정 요청 추가
        print("코디 수정 완료 제출: \(codiName)")

        // 수정 완료 후 이전 화면으로 이동
        navigationRouter.navigateBack()
    }
}
