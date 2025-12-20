//
//  AddCodiDetailViewModel.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

/// 코디 상세 설정(AddCodiDetailView) 화면에서 사용되는 ViewModel
/// - 역할:
///   - 상품 목록 조회 및 필터링
///   - 선택된 상품을 드래그 가능한 이미지로 보드에 배치
///   - 드래그 / 이동 / 확대 / 회전 상태 관리
///   - 최종 코디 데이터를 구성하여 다음 화면(AddCodiView)으로 전달
@MainActor
final class AddCodiDetailViewModel: ObservableObject, DraggableImageViewModelProtocol {

    // MARK: - Dependencies

    /// 화면 전환(뒤로가기, 다음 화면 이동)을 담당하는 라우터
    private let navigationRouter: NavigationRouter

    /// LookBook / Codi 관련 비즈니스 로직을 담당하는 UseCase
    private let useCase: LookBookUseCase

    // MARK: - Published State (Product / Filter)

    /// 전체 상품 목록
    /// UseCase를 통해 불러오며, 필터링의 원본 데이터로 사용된다.
    @Published var products: [ProductItem] = []

    /// 검색창에 입력된 텍스트
    /// 상품 이름 / 브랜드 필터링에 사용된다.
    @Published var searchText: String = ""

    /// 선택된 카테고리
    /// "전체" 선택 시 모든 상품을 표시한다.
    @Published var selectedCategory: String = "전체"

    /// 선택된 상품 ID 집합
    /// 최대 10개까지 선택 가능하도록 제어된다.
    @Published var selectedProductIds: Set<Int> = []

    // MARK: - Draggable Image State (Board)

    /// 보드 위에 배치된 드래그 가능한 이미지 목록
    /// 실제 코디를 구성하는 핵심 데이터
    @Published var images: [DraggableImageEntity] = []

    /// 현재 드래그 중인 이미지 ID
    /// 제스처 상태 관리 및 zIndex 처리에 사용
    @Published var currentlyDraggedID: Int?

    /// 코디 보드의 크기
    /// View에서 설정되며, 이미지 초기 배치 위치 계산에 사용된다.
    var boardSize: CGFloat = 300

    // MARK: - Computed Properties

    /// 검색어 + 카테고리를 기준으로 필터링된 상품 목록
    /// UI에서 실제로 보여지는 상품 리스트
    var filteredProducts: [ProductItem] {
        products.filter { product in
            let matchCategory = (selectedCategory == "전체")
            let matchSearch =
                searchText.isEmpty ||
                (product.name?.contains(searchText) ?? false) ||
                (product.brand?.contains(searchText) ?? false)
            return matchCategory && matchSearch
        }
    }

    // MARK: - Initializer

    /// ViewModel 생성자
    /// - Parameters:
    ///   - navigationRouter: 화면 전환을 담당하는 Router
    ///   - useCase: 상품/코디 관련 비즈니스 로직 UseCase
    init(
        navigationRouter: NavigationRouter,
        useCase: LookBookUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.useCase = useCase

        // 초기 진입 시 상품 목록 로드
        Task { await fetchProducts() }
    }

    // MARK: - Data Fetching

    /// 상품 목록을 불러온다.
    /// 실패 시 콘솔 로그만 남기며, 추후 에러 UI로 확장 가능
    func fetchProducts() async {
        do {
            self.products = try await useCase.fetchProductList()
        } catch {
            print("상품 목록 로드 실패: \(error)")
        }
    }

    // MARK: - Product Selection Logic

    /// 상품 선택/해제 토글 처리
    /// - 선택 시: 보드에 이미지 추가
    /// - 해제 시: 보드에서 이미지 제거
    /// - Parameter product: 선택된 상품
    func toggleProductSelection(_ product: ProductItem) {
        if selectedProductIds.contains(product.id) {
            // 선택 해제 → 이미지 제거
            selectedProductIds.remove(product.id)
            removeImage(productId: product.id)
        } else if selectedProductIds.count < 10 {
            // 선택 → 이미지 추가 (최대 10개 제한)
            selectedProductIds.insert(product.id)
            addImage(from: product)
        }
    }

    // MARK: - Image Management

    /// 선택된 상품을 드래그 가능한 이미지로 변환하여 보드에 추가
    /// 초기 위치는 보드 중앙 + 랜덤 오프셋으로 설정된다.
    private func addImage(from product: ProductItem) {
        let centerX = boardSize / 2
        let centerY = boardSize / 2
        let randomOffsetX = CGFloat.random(in: -30...30)
        let randomOffsetY = CGFloat.random(in: -30...30)

        let newImage = DraggableImageEntity(
            id: product.id,
            name: product.imageName,
            position: CGPoint(
                x: centerX + randomOffsetX,
                y: centerY + randomOffsetY
            ),
            scale: 1.0,
            rotationAngle: 0
        )

        images.append(newImage)
    }

    /// 특정 상품 ID에 해당하는 이미지를 보드에서 제거
    private func removeImage(productId: Int) {
        images.removeAll { $0.id == productId }
    }

    // MARK: - Image Manipulation (DraggableImageViewModelProtocol)

    /// 선택된 이미지를 배열의 마지막으로 이동시켜 가장 위로 표시
    func bringImageToFront(id: Int) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            let tapped = images.remove(at: index)
            images.append(tapped)
        }
    }

    /// 이미지 위치 업데이트 (드래그)
    func updateImagePosition(id: Int, newPosition: CGPoint) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].position = newPosition
        }
    }

    /// 이미지 스케일 업데이트 (확대/축소)
    func updateImageScale(id: Int, newScale: CGFloat) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].scale = newScale
        }
    }

    /// 이미지 회전값 업데이트
    func updateImageRotation(id: Int, newRotation: Double) {
        if let index = images.firstIndex(where: { $0.id == id }) {
            images[index].rotationAngle = newRotation
        }
    }

    // MARK: - Navigation & Actions

    /// 상단 백 버튼 탭 처리
    func handleBackTap() {
        navigationRouter.navigateBack()
    }

    /// 코디 상세 설정 완료 처리
    /// 현재 보드에 배치된 이미지 정보를 SelectedCodi로 구성해 AddCodiView로 전달
    func handleComplete() {
        let data = SelectedCodi(
            codiId: 0,
            imageURL: "",        // 단일 대표 이미지가 없으므로 빈 값
            name: "",
            memo: "",
            combinedItems: images // 보드 위에 배치된 모든 아이템
        )

        navigationRouter.navigate(
            to: .addCodi(
                lookbookId: 0,
                selectedCodiData: data
            )
        )
    }
}
