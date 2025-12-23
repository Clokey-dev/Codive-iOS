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
            // 상단 네비게이션 바 - "more" 에셋 적용
            CustomNavigationBar(
                title: "옷 상세",
                onBack: {
                    viewModel.navigateBack()
                },
                rightButton: .menu(
                    imageName: "more",
                    isSystemIcon: false,
                    isEnabled: true
                ) {
                    viewModel.handleMenuTap()
                }
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    // 1. 상품 이미지 영역
                    Image(viewModel.imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(Color.Codive.grayscale7)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

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
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .confirmationDialog("", isPresented: $viewModel.showActionSheet) {
            Button("편집") {
                viewModel.handleEdit()
            }
            Button("삭제", role: .destructive) {
                viewModel.handleDeleteRequest()
            }
            Button("취소", role: .cancel) {}
        }
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
        categoryId: 1,
        seasons: [.spring]
    )

    return closetDIContainer.makeClothDetailView(cloth: sampleCloth)
}
