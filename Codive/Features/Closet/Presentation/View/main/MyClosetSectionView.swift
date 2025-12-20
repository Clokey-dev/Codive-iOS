//
//  MyClosetSectionView.swift
//  Codive
//
//  Created by 황상환 on 12/13/25.
//

import SwiftUI

struct MyClosetSectionView: View {

    // MARK: - Properties
    let totalItems = 10
    private let navigationRouter: NavigationRouter

    // MARK: - Initializer
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("내 옷")
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)

                Spacer()

                Button(action: {
                    navigationRouter.navigate(to: .myCloset)
                }) {
                    HStack(spacing: 2) {
                        Text("더보기")
                        Image(systemName: "chevron.right")
                    }
                    .font(.codive_body3_regular)
                    .foregroundStyle(Color.Codive.grayscale2)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(stride(from: 0, to: totalItems, by: 2).map { $0 }, id: \.self) { i in
                        VStack(spacing: 12) {
                            ClothingCardView(
                                brand: i % 2 == 0 ? "나이키" : "No brand",
                                name: i % 2 == 0 ? "Cable knit cardigan" : "상의 > 니트"
                            )
                            
                            if i + 1 < totalItems {
                                ClothingCardView(
                                    brand: (i + 1) % 2 == 0 ? "나이키" : "No brand",
                                    name: (i + 1) % 2 == 0 ? "Cable knit cardigan" : "상의 > 니트"
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    let appDIContainer = AppDIContainer()
    let navigationRouter = appDIContainer.navigationRouter
    return MyClosetSectionView(navigationRouter: navigationRouter)
}
