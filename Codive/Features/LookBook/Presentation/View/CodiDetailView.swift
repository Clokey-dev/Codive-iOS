//
//  CodiDetailView.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

/// 코디 상세 화면
/// - 역할:
///   - 하나의 코디를 대표 이미지 중심으로 전시
///   - 코디에 포함된 의류 아이템을 하단 선택바로 탐색
///   - 코디 수정 / 삭제 액션 제공
///   - 코디 이름 및 메모 정보 표시
struct CodiDetailView: View {

    // MARK: - State Object

    /// 화면 상태 및 비즈니스 로직을 담당하는 ViewModel
    /// View 생명주기 동안 유지되도록 StateObject 사용
    @StateObject private var viewModel: CodiDetailViewModel

    // MARK: - Initializer

    /// View 생성자
    /// 외부에서 주입받은 ViewModel을 StateObject로 래핑한다.
    init(viewModel: CodiDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {

                // MARK: Top Navigation Bar

                /// 상단 네비게이션 바
                /// - 뒤로가기 버튼
                /// - 오버플로우 메뉴 (수정 / 삭제)
                topBar

                // MARK: Scrollable Content

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // MARK: Codi Display Area

                        /// 코디 대표 이미지 전시 영역
                        /// HomeHasCodiView와 동일한 레이아웃 구조를 사용
                        codiDisplayArea(width: geometry.size.width)

                        // MARK: Cloth Selector Toggle Area

                        /// 태그 버튼 클릭 시 노출되는 의류 선택 바
                        if viewModel.showClothSelector {
                            clothSelector
                        }

                        // MARK: Codi Info Section

                        /// 코디 이름 / 메모 정보 표시
                        if let detail = viewModel.codiDetail {
                            CodiInfoSection(
                                name: detail.name,
                                memo: detail.memo
                            )
                        }
                    }
                }
            }
        }
        // MARK: - View Lifecycle & Modifiers

        /// 기본 NavigationBar 숨김 (CustomNavigationBar 사용)
        .navigationBarHidden(true)

        /// 화면 배경색 설정
        .background(Color.white)

        /// 화면 진입 시 코디 상세 데이터 로드
        .onAppear {
            viewModel.fetchCodiDetail()
        }

        /// 코디 삭제 확인 Alert
        .alert("코디 삭제", isPresented: $viewModel.showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                viewModel.deleteCodi()
            }
        } message: {
            Text("해당 코디를 삭제하시겠습니까?\n한 번 삭제된 기록은 복구할 수 없습니다")
        }
    }

    // MARK: - Top Bar

    /// 상단 네비게이션 바 View
    /// - 제목: 코디 이름
    /// - 오른쪽 버튼: 수정 / 삭제 메뉴
    private var topBar: some View {
        CustomNavigationBar(
            title: viewModel.codiDetail?.name ?? "코디 상세",
            onBack: viewModel.handleBackTap,
            rightButton: .overflow(
                menuType: .closet,
                menuActions: [
                    { viewModel.navigateToEditCodi() },
                    { viewModel.requestDelete() }
                ]
            )
        )
        .zIndex(10)
        .padding(.leading, 15)
    }

    // MARK: - Codi Display Area

    /// 코디 대표 이미지 표시 영역
    /// - 정사각형 비율 유지
    /// - 배경 + 테두리 + 이미지 레이어 구조
    /// - 좌하단 태그 버튼으로 의류 선택바 토글
    private func codiDisplayArea(width: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {

            // MARK: Background Frame

            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
                .frame(
                    width: max(width - 40, 0),
                    height: max(width - 40, 0)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                }
                .padding(.horizontal, 20)

            // MARK: Codi Image

            /// 서버에서 내려온 코디 대표 이미지 표시
            if let detail = viewModel.codiDetail {
                RemoteFillImage(urlString: detail.imageURL)
                    .frame(width: width - 80, height: width - 80)
                    .position(
                        x: width / 2,
                        y: (width - 40) / 2
                    )
            }

            // MARK: Tag Button

            /// 의류 선택 바 토글 버튼
            Button(action: viewModel.toggleClothSelector) {
                Image("ic_tag")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 36)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Cloth Selector

    /// 코디에 포함된 의류 아이템 선택 바
    /// - 선택된 의류의 브랜드/이름 표시
    /// - 가로 스크롤 형태의 아이템 리스트
    private var clothSelector: some View {
        VStack(alignment: .leading, spacing: 8) {

            // MARK: Selected Cloth Info

            /// 현재 선택된 의류 정보 표시
            if let selectedIndex = viewModel.selectedIndex,
               selectedIndex < viewModel.clothItems.count {
                SelectedClothInfo(
                    entity: viewModel.clothItems[selectedIndex]
                )
                .padding(.horizontal, 20)
            }

            // MARK: Cloth Item List

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(
                        Array(viewModel.clothItems.enumerated()),
                        id: \.element.id
                    ) { index, item in
                        SelectableClothItem(
                            entity: CodiItemEntity(
                                id: item.id,
                                imageName: item.imageName,
                                x: 0,
                                y: 0,
                                width: 68,
                                height: 68
                            ),
                            isSelected: Binding(
                                get: { viewModel.selectedIndex == index },
                                set: { newValue in
                                    if newValue {
                                        viewModel.selectCloth(at: index)
                                    } else if viewModel.selectedIndex == index {
                                        viewModel.selectCloth(at: -1)
                                    }
                                }
                            )
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Supporting Views

/// 코디 이름 / 메모 표시 섹션
private struct CodiInfoSection: View {
    let name: String
    let memo: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("코디 명").font(.headline)
                Text(name).font(.body)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("개인 메모").font(.headline)
                Text(memo)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
}

/// 선택된 의류의 브랜드 / 이름 표시 뷰
private struct SelectedClothInfo: View {
    let entity: CodiItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entity.brand)
                .font(.caption)
                .foregroundColor(.gray)
            Text(entity.name)
                .font(.body)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

/// 서버 이미지 비율 유지 표시용 이미지 뷰
private struct RemoteFillImage: View {
    let urlString: String

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
    }
}
