//
//  SpecificLookBookViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/27/25.
//

import SwiftUI

/// 특정 룩북 상세 화면(SpecificLookBookView)에서 사용되는 ViewModel
/// - 역할:
///   - 선택된 룩북에 포함된 코디 목록 조회
///   - 코디 좋아요 상태 변경 처리
///   - 코디 추가 / 코디 상세 화면으로의 네비게이션 제어
@MainActor
final class SpecificLookBookViewModel: ObservableObject {

    // MARK: - Dependencies

    /// 화면 전환(뒤로가기, 코디 추가/상세 이동)을 담당하는 라우터
    private let navigationRouter: NavigationRouter

    /// LookBook / Codi 관련 비즈니스 로직을 담당하는 UseCase
    private let useCase: LookBookUseCase

    /// 현재 조회 중인 룩북 ID
    let lookbookId: Int

    // MARK: - Published State (Data)

    /// 해당 룩북에 포함된 코디 목록
    /// 그리드/리스트 UI에 바인딩된다.
    @Published var lookBookList: [LookBookEntity] = []

    /// 데이터 로딩 중 여부
    /// 로딩 인디케이터 표시 제어에 사용
    @Published var isLoading: Bool = false

    /// 에러 발생 시 사용자에게 표시할 메시지
    @Published var errorMessage: String?

    // MARK: - Initializer

    /// ViewModel 생성자
    /// - Parameters:
    ///   - navigationRouter: 화면 전환 담당 Router
    ///   - useCase: LookBook / Codi 비즈니스 로직 UseCase
    ///   - lookbookId: 조회할 룩북 ID
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase,
        lookbookId: Int
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.lookbookId = lookbookId
        print("SpecificLookBookViewModel initialized for LookBook ID: \(lookbookId)")
    }

    // MARK: - Data Fetching

    /// 특정 룩북에 속한 코디 목록을 불러온다.
    /// 로딩 상태 및 에러 상태를 함께 관리한다.
    func fetchCodis() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let list = try await useCase.fetchCodis(forLookbookId: lookbookId)
                self.lookBookList = list
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    // MARK: - Like Action

    /// 코디 좋아요 상태 변경 요청
    /// - Parameters:
    ///   - codyId: 좋아요 상태를 변경할 코디 ID
    ///   - isLiked: 변경할 좋아요 상태
    func toggleLike(codyId: Int, isLiked: Bool) {
        Task {
            do {
                try await useCase.toggleLike(codyId: codyId, isLiked: isLiked)
            } catch {
                self.errorMessage = "좋아요 상태 변경에 실패했습니다: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Navigation

    /// 코디 추가 화면(AddCodiView)으로 이동
    func navigateToAddCodi() {
        navigationRouter.navigate(to: .addCodi(lookbookId: lookbookId))
    }

    /// 코디 상세 화면(CodiDetailView)으로 이동
    /// - Parameter codiId: 선택된 코디 ID
    func navigateToCodiDetail(codiId: Int) {
        navigationRouter.navigate(to: .codiDetail(codiId: codiId))
    }

    /// 상단 백 버튼 탭 처리
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}

// MARK: - Preview / Mock

extension SpecificLookBookViewModel {

    /// SwiftUI Preview 및 테스트용 Mock ViewModel
    static var preview: SpecificLookBookViewModel {
        let mockRouter = NavigationRouter()
        let mockDataSource = LookBookDataSource()
        let mockRepository = LookBookRepositoryImpl(datasource: mockDataSource)
        let mockUseCase = LookBookUseCase(repository: mockRepository)

        return SpecificLookBookViewModel(
            navigationRouter: mockRouter,
            useCase: mockUseCase,
            lookbookId: 1
        )
    }
}
