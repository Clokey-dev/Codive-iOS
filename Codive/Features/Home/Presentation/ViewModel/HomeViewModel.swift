//
//  HomeViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var hasCodi: Bool = false
    @Published var selectedIndex: Int? = 0
    @Published var showClothSelector: Bool = false
    @Published var titleFrame: CGRect = .zero
    
    var menuActions: [() -> Void] {
        return [
            { print("코디 수정 tapped") },
            { print("룩북에 추가 tapped") },
            { print("코디 공유 tapped") }
        ]
    }

    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
        }
    }

    func selectCloth(at index: Int) {
        selectedIndex = index
    }

    func handleSearchTap() {
        print("검색 버튼 클릭")
    }

    func handleNotificationTap() {
        print("알림 버튼 클릭")
    }

    func handleCodiBoardTap() {
        print("코디보드 tapped")
    }

    func handleConfirmCodiTap() {
        print("이 코디 결정 tapped")
    }
}
