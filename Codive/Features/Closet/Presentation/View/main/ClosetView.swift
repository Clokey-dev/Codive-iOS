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

    // MARK: - Initializer
    init(closetDIContainer: ClosetDIContainer) {
        self.closetDIContainer = closetDIContainer
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                MyClosetSectionView(
                    viewModel: closetDIContainer.makeMyClosetSectionViewModel()
                )
                .padding(.top, 15)

                WardrobeReportView()

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
