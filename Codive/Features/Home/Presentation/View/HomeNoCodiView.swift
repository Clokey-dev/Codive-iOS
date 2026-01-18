//
//  HomeNoCodiView.swift
//  Codive
//
//  Created by 한금준 on 11/7/25.
//

import SwiftUI

struct HomeNoCodiView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: HomeViewModel

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header
            
            categoryButtons
            
            codiClothList
            
            Spacer()
            
            if !viewModel.isAllCategoriesEmpty {
                bottomButtons
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

// MARK: - View Components
private extension HomeNoCodiView {
    
    /// 상단 헤더 타이틀
    var header: some View {
        Text(TextLiteral.Home.noCodiTitle)
            .font(.codive_title1)
            .foregroundStyle(Color.Codive.grayscale1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)
    }
    
    /// 카테고리 편집 및 랜덤 설정 버튼 영역
    var categoryButtons: some View {
        HStack(spacing: 8) {
            CodiButton(iconName: "plus", title: TextLiteral.Home.edit) {
                viewModel.handleEditCategory()
            }
            CodiButton(iconName: "shuffle", title: TextLiteral.Home.random) {
                // TODO: 랜덤 코디 로직 연결 필요
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 16)
    }
    
    /// 카테고리별 의류 리스트 (가로 스크롤 영역들)
    var codiClothList: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.activeCategories) { category in
                let clothItems = viewModel.clothItemsByCategory[category.id] ?? []
                
                CodiClothView(
                    title: category.title,
                    items: clothItems,
                    isEmptyState: clothItems.isEmpty
                ) { newIndex in
                    // 사용자가 스크롤 할 때마다 ViewModel의 선택 인덱스 업데이트
                    viewModel.updateSelectedIndex(for: category.id, index: newIndex)
                }
                // 데이터 변경 시 뷰 갱신을 위한 식별자 지정
                .id("\(category.id)-\(clothItems.count)")
            }
        }
        .padding(.horizontal, 20)
    }
    
    /// 하단 액션 버튼 (코디판 이동 및 코디 확정)
    var bottomButtons: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width - 40
            let availableWidth = totalWidth - 16
            
            HStack(spacing: 16) {
                // 코디판 버튼 (1/3 비율)
                codiBoardButton(width: availableWidth / 3)
                
                // 결정하기 버튼 (2/3 비율)
                confirmButton(width: availableWidth * 2 / 3)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 48)
        .padding(.top, 24)
        .padding(.bottom, 48)
    }
    
    /// 코디판으로 이동하는 버튼
    func codiBoardButton(width: CGFloat) -> some View {
        Button(action: viewModel.handleCodiBoardTap) {
            Text(TextLiteral.Home.codiBoardTitle)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.main0)
                .frame(width: width, height: 48)
                .background(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.Codive.main0, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    /// 현재 조합으로 코디를 확정하는 버튼
    func confirmButton(width: CGFloat) -> some View {
        Button(action: viewModel.handleConfirmCodiTap) {
            Text(TextLiteral.Home.decesion)
                .font(.codive_title2)
                .foregroundStyle(.white)
                .frame(width: width, height: 48)
                .background(Color.Codive.main0)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
