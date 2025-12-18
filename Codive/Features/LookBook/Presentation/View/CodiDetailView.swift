//
//  CodiDetailView.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

struct CodiDetailView: View {
    // MARK: - Properties
    @StateObject private var viewModel: CodiDetailViewModel

    // MARK: - Initializer
    init(viewModel: CodiDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in // 너비 계산을 위해 추가
            VStack(spacing: 0) {
                topBar

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // HomeHasCodiView 스타일의 코디 전시 영역
                        codiDisplayArea(width: geometry.size.width)
                        
                        // 하단 의류 선택바 (HomeHasCodiView의 clothSelector와 동일한 로직)
                        if viewModel.showClothSelector {
                            clothSelector
                        }

                        // 상세 정보 섹션
                        if let detail = viewModel.codiDetail {
                            CodiInfoSection(name: detail.name, memo: detail.memo)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .onAppear {
            viewModel.fetchCodiDetail()
        }
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
    private var topBar: some View {
        CustomNavigationBar(
            title: viewModel.codiDetail?.name ?? "코디 상세",
            onBack: { viewModel.handleBackTap() },
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

    // MARK: - Codi Display Area (HomeHasCodiView 구조 반영)
    private func codiDisplayArea(width: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            // 배경 둥근 사각형
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1)) // Color.Codive.grayscale7 대응
                .frame(
                    width: max(width - 40, 0),
                    height: max(width - 40, 0)
                )
                .overlay(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                }
                .padding(.horizontal, 20)

            // 코디 이미지 표시 (DetailEntity의 정보를 바탕으로 렌더링)
            if let detail = viewModel.codiDetail {
                RemoteFillImage(urlString: detail.imageURL)
                    .frame(width: width - 80, height: width - 80)
                    .position(x: width / 2, y: (width - 40) / 2)
            }

            // 태그 버튼
            Button(action: viewModel.toggleClothSelector) {
                Image("ic_tag")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 36)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Cloth Selector (HomeHasCodiView 구조 반영)
    private var clothSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 선택된 아이템의 브랜드/이름 정보 (CodiDetail 특화 정보)
            if let selectedIndex = viewModel.selectedIndex,
               selectedIndex < viewModel.clothItems.count {
                SelectedClothInfo(entity: viewModel.clothItems[selectedIndex])
                    .padding(.horizontal, 20)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.clothItems.enumerated()), id: \.element.id) { index, item in
                        SelectableClothItem(
                            // CodiItemEntity는 위치/크기 필드가 필수라서 기본값을 채워준다 (썸네일 용도)
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
                                        viewModel.selectCloth(at: -1) // 해제 로직 (ViewModel에 맞춰 조정 가능)
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

// MARK: - Supporting Views (기존 구조 유지)

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
                Text(memo).font(.body).foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
}

private struct SelectedClothInfo: View {
    let entity: CodiItem
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entity.brand).font(.caption).foregroundColor(.gray)
            Text(entity.name).font(.body)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

private struct RemoteFillImage: View {
    let urlString: String
    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    CodiDetailView(viewModel: CodiDetailViewModel.preview)
}
