//
//  EditCategoryView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct EditCategoryView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: EditCategoryViewModel
    
    // MARK: - Initializer
    init(viewModel: EditCategoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView {
                VStack(spacing: 0) {
                    categoryHeader
                    categoryList
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomActionButtons
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .enableSwipeBack()
        .alert(TextLiteral.Home.changeAlertTitle, isPresented: $viewModel.showExitAlert) {
            alertButtons
        } message: {
            Text(TextLiteral.Home.changeAlertMessage)
        }
    }
}

// MARK: - View Components
private extension EditCategoryView {

    var navigationBar: some View {
        CustomNavigationBar(title: TextLiteral.Home.editCategoryTitle) {
            viewModel.handleBackTap()
        }
    }

    var categoryHeader: some View {
        Text("\(TextLiteral.Home.currentCategoryCount) (\(viewModel.totalCount)/7)")
            .font(.codive_title2)
            .foregroundStyle(Color.Codive.grayscale1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
    }

    var categoryList: some View {
        VStack(spacing: 24) {
            ForEach($viewModel.categories, id: \.id) { $category in
                CategoryCounterView(
                    title: category.title,
                    count: $category.itemCount,
                    totalCount: viewModel.totalCount,
                    isFixed: viewModel.isFixed(category: category)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    var bottomActionButtons: some View {
        HStack(spacing: 9) {
            CustomButton(
                text: TextLiteral.Home.reset,
                widthType: .half,
                styleType: .border
            ) {
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
    
    @ViewBuilder
    var alertButtons: some View {
        Button(TextLiteral.Common.cancel, role: .cancel) {
            viewModel.cancelExit()
        }
        Button(TextLiteral.Home.leave, role: .destructive) {
            viewModel.confirmExit()
        }
    }
}
