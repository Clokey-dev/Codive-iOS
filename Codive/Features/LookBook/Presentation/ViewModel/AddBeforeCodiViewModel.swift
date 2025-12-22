//
//  AddBeforeCodiViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

/// 코디 추가 전 단계(AddBeforeCodiView)에서 사용되는 ViewModel
/// - 역할:
///   - 이전에 저장된 코디 목록을 불러와 사용자에게 선택 UI 제공
///   - 특정 코디를 선택하면 AddCodiView로 이동하며 데이터 전달
///   - 화면 상태(로딩, 에러)를 관리
@MainActor
final class AddBeforeCodiViewModel: ObservableObject {

    // MARK: - Dependencies

    /// 화면 전환(뒤로가기, 다음 화면 이동)을 담당하는 라우터
    let navigationRouter: NavigationRouter

    /// LookBook / Codi 관련 비즈니스 로직을 담당하는 UseCase
    private let useCase: LookBookUseCase

    /// 현재 코디를 추가할 대상 룩북 ID
    let lookbookId: Int

    // MARK: - Published State (UI State)

    /// 이전에 저장된 코디 목록
    /// 리스트 화면에서 셀로 표시된다.
    @Published var lookBookList: [BeforeCodiEntity] = []

    /// 데이터 로딩 중 여부
    /// 로딩 인디케이터 표시 제어에 사용
    @Published var isLoading: Bool = false

    /// 에러 발생 시 사용자에게 표시할 메시지
    @Published var errorMessage: String?

    /// 선택된 코디 ID 집합
    /// 현재는 단일 선택 구조지만, 확장 가능성을 고려해 Set 사용
    @Published var selectedLookBookIds: Set<Int> = []

    // MARK: - Initializer

    /// ViewModel 생성자
    /// - Parameters:
    ///   - navigationRouter: 화면 이동을 담당하는 Router
    ///   - useCase: 코디/룩북 관련 비즈니스 로직 UseCase
    ///   - lookbookId: 코디를 추가할 대상 룩북 ID
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase,
        lookbookId: Int
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.lookbookId = lookbookId
    }

    // MARK: - Data Fetching

    /// 이전에 저장된 코디 목록을 서버(또는 더미 데이터)에서 불러온다.
    /// 로딩 상태와 에러 상태를 함께 관리한다.
    func fetchLookBooks() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let list = try await useCase.fetchBeforeCodiList()
                self.lookBookList = list
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    // MARK: - Selection Logic

    /// 특정 코디 선택 처리
    /// 현재는 단일 선택만 허용하며, 선택 즉시 AddCodiView로 이동한다.
    /// - Parameter id: 선택된 코디 ID
    func toggleSelection(id: Int) {
        if let selectedCodi = lookBookList.first(where: { $0.id == id }) {
            navigateToAddCodiWithData(codi: selectedCodi)
        }
    }

    // MARK: - Navigation

    /// 상단 백 버튼 탭 처리
    func handleBackTap() {
        navigationRouter.navigateBack()
    }

    /// 선택한 이전 코디 데이터를 AddCodiView로 전달하며 이동
    /// - Parameter codi: 선택된 이전 코디 엔티티
    func navigateToAddCodiWithData(codi: BeforeCodiEntity) {
        let selectedData = SelectedCodi(
            codiId: 0,
            imageURL: codi.imageURL,
            name: codi.name,
            memo: codi.memo
        )

        navigationRouter.navigate(
            to: .addCodi(
                lookbookId: lookbookId,
                selectedCodiData: selectedData
            )
        )
    }

    /// 특정 룩북 상세 화면으로 이동 (확장/재사용용)
    func navigateToSpecificLookBook(id: Int) {
        navigationRouter.navigate(to: .specificLookbook(lookbookId: id))
    }
}
