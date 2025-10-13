//
//  AddView.swift
//  Codive
//
//  Created by 황상환 on 9/24/25.
//

import SwiftUI

struct AddView: View {
    
    // MARK: - Properties
    @StateObject private var navigationRouter: NavigationRouter
    private let addDIContainer: AddDIContainer
    
    // MARK: - Initializer
    init(addDIContainer: AddDIContainer) {
        self.addDIContainer = addDIContainer
        _navigationRouter = StateObject(wrappedValue: addDIContainer.navigationRouter)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            VStack(spacing: 0) {
                // Title
                Text(TextLiteral.Add.mainTitle)
                    .font(.codive_title1)
                    .padding(.top, 20)
                
                // Question Text
                Text(TextLiteral.Add.questionTitle)
                    .font(.codive_title1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 38)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Clothes Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(TextLiteral.Add.clothesSectionTitle)
                                .font(.system(size: 18, weight: .bold))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                // AI Auto Add
                                AddOptionButton(
                                    iconName: "ai_icon",
                                    iconBackgroundColor: .orange,
                                    title: TextLiteral.Add.aiAutoAddTitle,
                                    description: TextLiteral.Add.aiAutoAddDescription
                                ) {
                                    // TODO: AI 자동추가 액션
                                }
                                
                                // Manual Add
                                AddOptionButton(
                                    iconName: "cloth_icon",
                                    iconBackgroundColor: .orange,
                                    title: TextLiteral.Add.manualAddTitle,
                                    description: TextLiteral.Add.manualAddDescription
                                ) {
                                    // TODO: 직접 추가 액션
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 48)
                        
                        // MARK: - Record Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(TextLiteral.Add.recordSectionTitle)
                                .font(.system(size: 18, weight: .bold))
                                .padding(.horizontal, 20)
                            
                            // Record Add
                            AddOptionButton(
                                iconName: "feed_icon",
                                iconBackgroundColor: .orange,
                                title: TextLiteral.Add.recordAddTitle,
                                description: TextLiteral.Add.recordAddDescription
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
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .recordAdd:
                    addDIContainer.makeRecordAddView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    let appDIContainer = AppDIContainer()
    let addDIContainer = appDIContainer.makeAddDIContainer()
    return AddView(addDIContainer: addDIContainer)
}
