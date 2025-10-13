//
//  EditCategoryView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct EditCategoryView: View {
    @StateObject private var viewModel = EditCategoryViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            /// 네비게이션 바
            CustomNavigationBar(title: "카테고리 편집") {
                print("뒤로가기")
            }
            
            ScrollView {
                VStack {
                    /// 현재 카테고리 개수 표시
                    Text("현재 카테고리(\(viewModel.totalCount)/10)")
                        .font(Font.codive_title2)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
                    
                    /// 카테고리별 카운터 리스트
                    VStack(spacing: 24) {
                        ForEach($viewModel.categories) { $category in
                            CategoryCounterView(
                                title: category.title,
                                count: $category.count,
                                totalCount: viewModel.totalCount
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 9) {
                    CustomButton(text: "초기화", widthType: .outlinedHalf) {
                        viewModel.resetCounts()
                    }
                    CustomButton(text: "적용하기", widthType: .half) {
                        viewModel.applyChanges()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
        .background(Color.white)
    }
}

#Preview {
    EditCategoryView()
}
