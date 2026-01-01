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
                    Text("\(TextLiteral.Home.currentCategoryCount) (\(viewModel.totalCount)/7)")
                        .font(Font.codive_title2)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
                    
                    VStack(spacing: 24) {
                        ForEach($viewModel.categories, id: \.id) { $category in
                            CategoryCounterView(
                                title: category.title,
                                count: $category.itemCount,
                                totalCount: viewModel.totalCount,
                                isFixed: viewModel.isFixed(category: category) // 고정 정보 전달
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
                .background(alignment: .center) {
                    Color.white
                }
            }
        }
        .navigationBarHidden(true)
        .background(alignment: .center) {
            Color.white
        }
        .alert(TextLiteral.Home.changeAlertTitle, isPresented: $viewModel.showExitAlert) {
            Button(TextLiteral.Common.cancel, role: .cancel) {
                viewModel.cancelExit()
            }
            Button(TextLiteral.Home.leave, role: .destructive) {
                viewModel.confirmExit()
            }
        } message: {
            Text(TextLiteral.Home.changeAlertMessage)
        }
    }
}
