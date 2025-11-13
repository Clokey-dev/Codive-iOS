//
//  EditCategoryView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct EditCategoryView: View {
    @StateObject private var viewModel: EditCategoryViewModel
    
    init(viewModel: EditCategoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: TextLiteral.Home.editCategoryTitle) {
                viewModel.handleBackTap()
            }
            
            ScrollView {
                VStack {
                    Text("현재 카테고리 (\(viewModel.totalCount)/10)")
                        .font(Font.codive_title2)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
                    
                    VStack(spacing: 24) {
                        ForEach($viewModel.categories, id: \.id) { $category in
                            CategoryCounterView(
                                title: category.title,
                                count: $category.itemCount,
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
                    CustomButton(text: TextLiteral.Home.reset, widthType: .half, styleType: .border) {
                        viewModel.resetCounts()
                    }
                    CustomButton(
                        text: TextLiteral.Home.apply,
                        widthType: .half,
                        isEnabled: viewModel.isApplyButtonEnabled
                    ) {
                        viewModel.applyChanges()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .alert("변경사항이 있습니다", isPresented: $viewModel.showExitAlert) {
            Button("취소", role: .cancel) {
                viewModel.cancelExit()
            }
            Button("나가기", role: .destructive) {
                viewModel.confirmExit()
            }
        } message: {
            Text("변경사항을 저장하지 않고 나가시겠습니까?")
        }
    }
}
