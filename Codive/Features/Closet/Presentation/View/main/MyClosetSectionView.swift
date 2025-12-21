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

                Button(action: {
                    viewModel.navigateToMyCloset()
                }) {
                    HStack(spacing: 2) {
                        Text("더보기")
                        Image(systemName: "chevron.right")
                    }
                    .font(.codive_body3_regular)
                    .foregroundStyle(Color.Codive.grayscale2)
                }
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
                    buttonText: "옷 추가하기",
                    action: {
                        // TODO: 옷 추가 네비게이션
                    }
                )
                .frame(height: 200)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // 2개씩 묶어서 세로로 표시
                        ForEach(stride(from: 0, to: viewModel.clothItems.count, by: 2).map { $0 }, id: \.self) { i in
                            VStack(spacing: 12) {
                                // 첫 번째 아이템
                                ClothingCardView(
                                    brand: viewModel.clothItems[i].brand ?? "No brand",
                                    name: viewModel.clothItems[i].name ?? "이름 없음"
                                )
                                .onTapGesture {
                                    viewModel.navigateToClothDetail(viewModel.clothItems[i])
                                }

                                // 두 번째 아이템 (있을 경우)
                                if i + 1 < viewModel.clothItems.count {
                                    ClothingCardView(
                                        brand: viewModel.clothItems[i + 1].brand ?? "No brand",
                                        name: viewModel.clothItems[i + 1].name ?? "이름 없음"
                                    )
                                    .onTapGesture {
                                        viewModel.navigateToClothDetail(viewModel.clothItems[i + 1])
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .task {
            await viewModel.loadClothItems()
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
