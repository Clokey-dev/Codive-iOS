//
//  AddView.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import SwiftUI

struct AddView: View {
    
    // MARK: - Properties
    @EnvironmentObject private var navigationRouter: NavigationRouter
    private let addDIContainer: AddDIContainer
    
    // MARK: - Initializer
    init(addDIContainer: AddDIContainer) {
        self.addDIContainer = addDIContainer
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text(TextLiteral.Add.title)
                .font(.codive_title1)
                .padding(.top, 20)
            
            // Question Text
            Text(TextLiteral.Add.question)
                .font(.codive_title1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 38)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
            
            ScrollView {
                VStack {
                    // MARK: - Clothes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(TextLiteral.Add.clothesSectionTitle)
                            .font(.codive_title2)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // AI Auto Add
                            AddOptionButton(
                                iconName: "ai_icon",
                                title: TextLiteral.Add.clothesAiAutoTitle,
                                description: TextLiteral.Add.clothesAiAutoDescription
                            ) {
                                // TODO: AI 자동추가 액션
                            }
                            
                            // Manual Add
                            AddOptionButton(
                                iconName: "cloth_icon",
                                title: TextLiteral.Add.clothesManualTitle,
                                description: TextLiteral.Add.clothesManualDescription
                            ) {
                                navigationRouter.navigate(to: AppDestination.clothPhotoSelect)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 48)
                    
                    // MARK: - Record Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(TextLiteral.Add.recordTitle)
                            .font(.codive_title2)
                            .padding(.horizontal, 20)
                        
                        // Record Add
                        AddOptionButton(
                            iconName: "feed_icon",
                            title: TextLiteral.Add.recordTitle,
                            description: TextLiteral.Add.recordDescription
                        ) {
                            navigationRouter.navigate(to: AppDestination.recordAdd)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            Spacer()
        }
        .background(Color.white)
    }
}

#Preview {
    let appDIContainer = AppDIContainer()
    let addDIContainer = appDIContainer.makeAddDIContainer()
    return AddView(addDIContainer: addDIContainer)
}
