//
//  MyClosetSectionView.swift
//  Codive
//
//  Created by 황상환 on 12/13/25.
//

import SwiftUI

struct MyClosetSectionView: View {

    // MARK: - Properties
    @StateObject private var viewModel: MyClosetSectionViewModel

    // MARK: - Initializer
    init(viewModel: MyClosetSectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("내 옷")
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)

                Spacer()

                Button(
                    action: {
                        viewModel.navigateToMyCloset()
                    },
                    label: {
                        HStack(spacing: 2) {
                            Text("더보기")
                            Image(systemName: "chevron.right")
                        }
                        .font(.codive_body3_regular)
                        .foregroundStyle(Color.Codive.grayscale2)
                    }
                )
            }
            .padding(.horizontal, 20)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else if viewModel.clothItems.isEmpty {
                EmptyStateView(
                    headerTitle: nil,
                    title: "옷장이 비어있어요",
                    description: "옷을 추가해보세요",
                    buttonText: "옷 추가하기"
                ) {
                    // TODO: 옷 추가 네비게이션
                }
                .frame(height: 200)
            } else {
                clothGridSection
            }
        }
        .task {
            await viewModel.loadClothItems()
        }
    }

    // MARK: - Cloth Grid Section

    @ViewBuilder
    private var clothGridSection: some View {
        let itemCount = viewModel.clothItems.count
        let showTwoRows = itemCount >= 8

        ScrollView(.horizontal, showsIndicators: false) {
            if showTwoRows {
                // 8개 이상: 2행 x 4열 (총 8개)
                twoRowGrid
            } else {
                // 7개 이하: 1행 (최대 4개)
                oneRowGrid
            }
        }
    }

    /// 1행 레이아웃 (7개 이하일 때, 최대 4개 표시)
    @ViewBuilder
    private var oneRowGrid: some View {
        HStack(spacing: 12) {
            ForEach(Array(viewModel.clothItems.prefix(4).enumerated()), id: \.element.id) { _, cloth in
                clothCard(for: cloth)
            }
        }
        .padding(.horizontal, 20)
    }

    /// 2행 레이아웃 (8개 이상일 때, 총 8개 표시)
    @ViewBuilder
    private var twoRowGrid: some View {
        let displayItems = Array(viewModel.clothItems.prefix(8))

        HStack(spacing: 12) {
            // 4개씩 묶어서 세로로 표시
            ForEach(stride(from: 0, to: displayItems.count, by: 2).map { $0 }, id: \.self) { i in
                VStack(spacing: 12) {
                    // 첫 번째 아이템 (위)
                    clothCard(for: displayItems[i])

                    // 두 번째 아이템 (아래, 있을 경우)
                    if i + 1 < displayItems.count {
                        clothCard(for: displayItems[i + 1])
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    /// 개별 옷 카드
    @ViewBuilder
    private func clothCard(for cloth: Cloth) -> some View {
        ClothingCardView(
            imageUrl: cloth.imageUrl,
            brand: cloth.brand ?? "No brand",
            name: cloth.name ?? "이름 없음"
        )
        .onTapGesture {
            viewModel.navigateToClothDetail(cloth)
        }
    }
}

#Preview {
    let appDIContainer = AppDIContainer()
    let closetDIContainer = appDIContainer.closetDIContainer
    return MyClosetSectionView(
        viewModel: closetDIContainer.makeMyClosetSectionViewModel()
    )
}
