//
//  ClosetView.swift
//  Codive
//
//  Created by 황상환 on 12/15/25.
//

import SwiftUI

struct ClosetView: View {

    // MARK: - Properties
    @StateObject private var navigationRouter: NavigationRouter
    private let closetDIContainer: ClosetDIContainer

    // MARK: - Initializer
    init(closetDIContainer: ClosetDIContainer) {
        self.closetDIContainer = closetDIContainer
        _navigationRouter = StateObject(wrappedValue: closetDIContainer.navigationRouter)
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                MyClosetSectionView(navigationRouter: navigationRouter)
                    .padding(.top, 15)

                WardrobeReportView()

                MyLookbookSectionView()
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
