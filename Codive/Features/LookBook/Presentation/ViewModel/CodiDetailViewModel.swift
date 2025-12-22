//
//  CodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

/// 코디 상세 화면(CodiDetailView)에서 사용되는 ViewModel
/// - 역할:
///   - 특정 코디의 상세 정보 조회
///   - 코디에 포함된 의류 아이템 목록 구성
///   - 의류 선택 UI 상태 관리
///   - 코디 수정 / 삭제 네비게이션 처리
@MainActor
final class CodiDetailViewModel: ObservableObject {

    // MARK: - Dependencies

    /// 화면 전환(뒤로가기, 수정 화면 이동 등)을 담당하는 라우터
    private let navigationRouter: NavigationRouter

    /// LookBook / Codi 관련 비즈니스 로직을 담당하는 UseCase
    private let useCase: LookBookUseCase

    /// 현재 조회 중인 코디 ID
    let codiId: Int

    // MARK: - Published State (Data)

    /// 코디 상세 정보
    /// 서버(또는 더미 데이터)에서 불러온 원본 데이터
    @Published var codiDetail: CodiDetailEntity?

    /// 데이터 로딩 중 여부
    /// 로딩 인디케이터 표시 제어에 사용
    @Published var isLoading: Bool = false

    /// 에러 발생 시 사용자에게 표시할 메시지
    @Published var errorMessage: String?

    // MARK: - Published State (UI Control)

    /// 하단 의류 선택 UI 표시 여부
    @Published var showClothSelector: Bool = false

    /// 현재 선택된 의류 인덱스
    /// 상의/하의/신발 중 어떤 항목이 선택되었는지 나타냄
    @Published var selectedIndex: Int?

    /// 삭제 확인 Alert 표시 여부
    @Published var showDeleteAlert: Bool = false

    // MARK: - Computed Properties

    /// 코디에 포함된 의류 아이템 목록
    /// 상의 / 하의 / 신발 정보를 UI에서 공통 모델로 사용하기 위해 가공한다.
    var clothItems: [CodiItem] {
        guard let detail = codiDetail else { return [] }
        return [
            CodiItem(id: 1, imageName: detail.topImageURL, brand: "Brand", name: "Top"),
            CodiItem(id: 2, imageName: detail.bottomImageURL, brand: "Brand", name: "Bottom"),
            CodiItem(id: 3, imageName: detail.shoeImageURL, brand: "Brand", name: "Shoes")
        ]
    }

    // MARK: - Initializer

    /// ViewModel 생성자
    /// - Parameters:
    ///   - navigationRouter: 화면 전환을 담당하는 Router
    ///   - useCase: LookBook / Codi 비즈니스 로직 UseCase
    ///   - codiId: 조회할 코디 ID
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase,
        codiId: Int
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
        self.codiId = codiId
    }

    // MARK: - Data Fetching

    /// 코디 상세 정보를 불러온다.
    /// 로딩 상태 및 에러 상태를 함께 관리한다.
    func fetchCodiDetail() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let detail = try await useCase.fetchCodiDetail(codiId: codiId)
                self.codiDetail = detail
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Cloth Selection Logic

    /// 의류 선택 UI 표시/숨김 토글
    /// 닫힐 경우 선택된 인덱스를 초기화한다.
    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
            if !showClothSelector {
                selectedIndex = nil
            }
        }
    }

    /// 특정 의류 아이템 선택 처리
    /// - Parameter index: 선택된 의류 인덱스
    func selectCloth(at index: Int) {
        selectedIndex = index
    }

    // MARK: - Navigation

    /// 코디 수정 화면(EditCodiView)으로 이동
    func navigateToEditCodi() {
        guard let detail = codiDetail else { return }

        let data = SelectedCodi(
            codiId: codiId,
            imageURL: detail.imageURL,
            name: detail.name,
            memo: detail.memo
        )

        navigationRouter.navigate(
            to: .editCodi(
                lookbookId: 0,
                selectedCodiData: data
            )
        )
    }

    /// 삭제 버튼 탭 시 Alert 표시 요청
    func requestDelete() {
        showDeleteAlert = true
    }

    /// 코디 삭제 처리
    /// 실제 API 연동 전까지는 로그 출력 후 뒤로 이동
    func deleteCodi() {
        Task {
            print("코디 \(codiId) 삭제 완료")
            navigationRouter.navigateBack()
        }
    }

    /// 상단 백 버튼 탭 처리
    func handleBackTap() {
        navigationRouter.navigateBack()
    }
}
