//
//  ClothDetailView.swift
//  Codive
//
//  Created by 황상환 on 12/21/25.
//

import SwiftUI

struct ClothDetailView: View {
    @StateObject private var viewModel: ClothDetailViewModel

    // MARK: - Initializer
    init(viewModel: ClothDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 네비게이션 바
            CustomNavigationBar(
                title: "옷 상세",
                onBack: {
                    viewModel.navigateBack()
                },
                rightButton: .overflow(
                    menuType: .closet,
                    menuActions: [
                        { viewModel.handleEdit() },
                        { viewModel.handleDeleteRequest() }
                    ],
                    isExpanded: viewModel.isOverflowMenuExpanded,
                    onToggle: viewModel.toggleOverflowMenu,
                    onClose: viewModel.closeOverflowMenu
                )
            )
            .zIndex(10)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 32) {
                        // 1. 상품 이미지 영역
                        clothImageView

                        // 2. 정보 리스트 영역
                        VStack(spacing: 20) {
                            infoRow(label: "카테고리", value: viewModel.categoryText)
                            infoRow(label: "계절", value: viewModel.seasonText)
                            infoRow(label: "옷 이름", value: viewModel.name)
                            infoRow(label: "브랜드", value: viewModel.brand)
                            infoRow(label: "구매 url", value: viewModel.purchaseUrl)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isOverflowMenuExpanded {
                        viewModel.closeOverflowMenu()
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.isOverflowMenuExpanded {
                viewModel.closeOverflowMenu()
            }
        }
        .task {
            await viewModel.fetchDetail()
        }
        .toolbar(.hidden, for: .navigationBar)
        .enableSwipeBack()
        .background(Color.white)
        .alert("옷 삭제", isPresented: $viewModel.showDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                Task {
                    await viewModel.confirmDelete()
                }
            }
        } message: {
            Text("이 옷을 삭제하시겠습니까?")
        }
    }
    
    // 이미지 뷰
    @ViewBuilder
    private var clothImageView: some View {
        let urlString = viewModel.imageUrl
        if !urlString.isEmpty, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.Codive.grayscale7)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(Color.Codive.grayscale6)
                case .failure:
                    Rectangle()
                        .fill(Color.Codive.grayscale7)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(Color.Codive.grayscale4)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Rectangle()
                .fill(Color.Codive.grayscale7)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // 공통 정보 행 컴포넌트
    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 20) {
            // 라벨 영역 (고정 너비 60px)
            Text(label)
                .font(.codive_body1_medium)
                .foregroundStyle(Color.Codive.grayscale1)
                .frame(width: 60, alignment: .leading)
            
            // 값 영역 (유연한 너비 및 자동 줄바꿈 대응)
            Text(value)
                .font(.codive_body1_regular)
                .foregroundStyle(Color.Codive.grayscale3)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let appDIContainer = AppDIContainer()
    let closetDIContainer = appDIContainer.closetDIContainer

    let sampleCloth = Cloth(
        id: 1,
        imageUrl: "sampleCloth",
        name: "스트링 리본 핑크 셔링 블라우스",
        brand: "로렌하이",
        purchaseUrl: "www.http://",
        mainCategory: "상의",
        subCategory: "블라우스",
        seasons: [.spring]
    )

    closetDIContainer.makeClothDetailView(cloth: sampleCloth)
}
