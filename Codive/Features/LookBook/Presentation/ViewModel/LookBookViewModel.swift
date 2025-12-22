//
//  LookBookViewModel.swift
//  Codive
//
//  Created by 한금준 on 11/22/25.
//

import SwiftUI

/// 룩북 메인 화면(LookBookView)에서 사용되는 ViewModel
/// - 역할:
///   - 룩북 목록 조회 및 상태 관리
///   - 편집 모드(선택/삭제) 제어
///   - 룩북 추가/삭제 다이얼로그 상태 관리
///   - 상세 화면으로의 네비게이션 처리
@MainActor
final class LookBookViewModel: ObservableObject {

    // MARK: - Dependencies

    /// 화면 전환(뒤로가기, 상세 화면 이동 등)을 담당하는 라우터
    let navigationRouter: NavigationRouter

    /// LookBook 관련 비즈니스 로직을 담당하는 UseCase
    private let useCase: LookBookUseCase

    // MARK: - Published State (Data)

    /// 화면에 표시되는 룩북 목록
    @Published var lookBookList: [LookBookEntity] = []

    /// 데이터 로딩 중 여부
    /// 로딩 인디케이터 표시 제어에 사용
    @Published var isLoading: Bool = false

    /// 에러 발생 시 사용자에게 표시할 메시지
    @Published var errorMessage: String?

    // MARK: - Published State (Editing)

    /// 편집 모드 여부
    /// true일 경우 다중 선택 및 삭제 UI 활성화
    @Published var isEditing: Bool = false

    /// 선택된 룩북 ID 집합
    /// 편집 모드에서 삭제 대상 관리에 사용
    @Published var selectedLookBookIds: Set<Int> = []

    // MARK: - Published State (Dialog / Alert)

    /// 룩북 삭제 확인 Alert 표시 여부
    @Published var isShowingDeleteAlert: Bool = false

    /// 룩북 추가 다이얼로그 표시 여부
    @Published var isShowingAddDialog: Bool = false

    /// 추가 다이얼로그 취소 시 확인 Alert 표시 여부
    @Published var isShowingCancelConfirmAlert: Bool = false

    // MARK: - Initializer

    /// ViewModel 생성자
    /// - Parameters:
    ///   - navigationRouter: 화면 전환을 담당하는 Router
    ///   - useCase: LookBook 비즈니스 로직 UseCase
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase
    }

    // MARK: - Data Fetching

    /// 룩북 목록을 불러온다.
    /// - 최초 진입 시
    /// - 삭제 완료 후
    /// 에 호출된다.
    func fetchLookBooks() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let list = try await useCase.fetchLookBookList()
                self.lookBookList = list

                // 룩북이 하나도 없을 경우 추가 다이얼로그 자동 표시
                if list.isEmpty {
                    self.isShowingAddDialog = true
                }
            } catch {
                self.errorMessage = "데이터 로드에 실패했습니다: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    // MARK: - Editing Actions

    /// 편집 모드 토글
    /// 종료 시 선택된 룩북 목록을 초기화한다.
    func toggleEditingMode() {
        isEditing.toggle()
        if !isEditing {
            selectedLookBookIds = []
        }
    }

    /// 특정 룩북 선택/해제 처리
    /// - Parameter id: 선택된 룩북 ID
    func toggleSelection(id: Int) {
        if selectedLookBookIds.contains(id) {
            selectedLookBookIds.remove(id)
        } else {
            selectedLookBookIds.insert(id)
        }
    }

    /// 삭제 버튼 탭 처리
    /// 실제 삭제는 완료 버튼을 통해 진행된다.
    func handleDeleteAction() {
        toggleEditingMode()
    }

    /// 삭제 완료 버튼 탭 처리
    /// 선택된 룩북이 없으면 편집 모드만 종료한다.
    func handleCompleteAction() {
        guard !selectedLookBookIds.isEmpty else {
            toggleEditingMode()
            return
        }
        isShowingDeleteAlert = true
    }

    /// 삭제 확인 Alert에서 삭제 버튼 탭 시 호출
    /// - Alert를 먼저 닫고(=dismiss), 즉시 로딩 오버레이를 띄운 뒤
    ///   실제 삭제 로직(confirmDelete)을 실행한다.
    func beginDelete() {
        isShowingDeleteAlert = false
        isLoading = true
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            self.confirmDelete()
        }
    }

    /// 삭제 확인 Alert에서 확인 버튼 탭 시 호출
    /// 실제 삭제 API를 호출하고 목록을 갱신한다.
    func confirmDelete() {
        let idsToDelete = Array(selectedLookBookIds)

        Task {
            do {
                try await useCase.deleteLookBooks(ids: idsToDelete)
                self.isLoading = false
                self.fetchLookBooks()
                self.toggleEditingMode()
            } catch {
                self.errorMessage = "룩북 삭제에 실패했습니다: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    // MARK: - Dialog Actions

    /// 룩북 추가 다이얼로그 표시/숨김 토글
    func toggleAddDialog() {
        isShowingAddDialog.toggle()
    }

    /// 추가 다이얼로그 취소 버튼 탭 처리
    /// 취소 확인 Alert를 표시한다.
    func handleDialogCancelTap() {
        isShowingCancelConfirmAlert = true
    }

    /// 취소 확인 Alert에서 확인 버튼 탭 시 호출
    /// 추가 다이얼로그를 닫는다.
    func confirmCancelDialog() {
        isShowingCancelConfirmAlert = false
        isShowingAddDialog = false
    }

    /// 새로운 룩북 추가 처리
    /// - Parameter title: 입력받은 룩북 제목
    func handleAddLookBook(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        // 새로운 임시 룩북 엔티티 생성
        let newLookBook = LookBookEntity(
            id: Int.random(in: 1000...9999), // 실제 서버 연동 시 서버에서 생성된 ID 사용
            imageURL: "https://via.placeholder.com/160",
            cardTitle: trimmedTitle
        )

        // 리스트에 추가 (애니메이션 포함)
        withAnimation {
            self.lookBookList.append(newLookBook)
        }

        isShowingAddDialog = false
    }

    // MARK: - Navigation

    /// 상단 백 버튼 탭 처리
    /// - 편집 중이면 편집 모드 종료
    /// - 아니면 이전 화면으로 이동
    func handleBackTap() {
        if isEditing {
            toggleEditingMode()
        } else {
            navigationRouter.navigateBack()
        }
    }

    /// 특정 룩북 상세 화면으로 이동
    /// - Parameter id: 선택된 룩북 ID
    func navigateToSpecificLookBook(id: Int) {
        navigationRouter.navigate(to: .specificLookbook(lookbookId: id))
    }
}
