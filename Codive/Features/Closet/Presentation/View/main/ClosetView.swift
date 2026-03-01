//
//  ClosetView.swift
//  Codive
//
//  Created by 황상환 on 12/15/25.
//

import SwiftUI

struct ClosetView: View {

    // MARK: - Properties
    private let closetDIContainer: ClosetDIContainer
    @StateObject private var myClosetSectionViewModel: MyClosetSectionViewModel

    // MARK: - Initializer
    init(closetDIContainer: ClosetDIContainer) {
        self.closetDIContainer = closetDIContainer
        _myClosetSectionViewModel = StateObject(wrappedValue: closetDIContainer.makeMyClosetSectionViewModel())
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                MyClosetSectionView(
                    viewModel: myClosetSectionViewModel
                )
                .padding(.top, 15)

                WardrobeReportView(
                    isEmpty: myClosetSectionViewModel.clothItems.isEmpty,
                    onTapReport: {
                        closetDIContainer.navigationRouter.navigate(to: .wardrobeReport)
                    },
                    onAddCloth: {
                        myClosetSectionViewModel.navigateToAddCloth()
                    }
                )

                MyLookbookSectionView(
                    viewModel: closetDIContainer.makeMyLookBookSectionViewModel()
                )
                Spacer(minLength: 45)
            }
        }
    }
}

#Preview {
    let appDIContainer = AppDIContainer()
    let closetDIContainer = appDIContainer.closetDIContainer
    return ClosetView(closetDIContainer: closetDIContainer)
}
