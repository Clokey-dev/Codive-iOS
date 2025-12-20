//
//  ClothDetailView.swift
//  Codive
//
//  Created by 황상환 on 12/21/25.
//

import SwiftUI

struct ClothDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 임시 데이터 (실제 데이터 모델 연동 가능)
    let brand: String = "로렌하이"
    let name: String = "스트링 리본 핑크 셔링 블라우스"
    let category: String = "상의 > 블라우스"
    let season: String = "봄"
    let purchaseUrl: String = "www.http://"
    let imageUrl: String = "sampleCloth"

    var body: some View {
        VStack(spacing: 0) {
            // 상단 네비게이션 바 - "more" 에셋 적용
            CustomNavigationBar(
                title: "옷 상세",
                onBack: {
                    dismiss()
                },
                rightButton: .menu(
                    imageName: "more",
                    isSystemIcon: false,
                    isEnabled: true
                ) {
                    print("메뉴 클릭")
                }
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    // 1. 상품 이미지 영역
                    Image(imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(Color.Codive.grayscale7)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // 2. 정보 리스트 영역
                    VStack(spacing: 20) {
                        infoRow(label: "카테고리", value: category)
                        infoRow(label: "계절", value: season)
                        infoRow(label: "옷 이름", value: name)
                        infoRow(label: "브랜드", value: brand)
                        infoRow(label: "구매 url", value: purchaseUrl)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
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
    ClothDetailView()
}
