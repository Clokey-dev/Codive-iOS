//
//  EditCategoryViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

@MainActor
final class EditCategoryViewModel: ObservableObject {
    @Published var topCount = 0
    @Published var bottomCount = 0
    @Published var skirtCount = 0
    @Published var outerCount = 0
    @Published var shoeCount = 0
    @Published var bagCount = 0
    @Published var accessoryCount = 0
    
    var totalCount: Int {
        topCount + bottomCount + skirtCount + outerCount + shoeCount + bagCount + accessoryCount
    }
    
    func resetCounts() {
        topCount = 0
        bottomCount = 0
        skirtCount = 0
        outerCount = 0
        shoeCount = 0
        bagCount = 0
        accessoryCount = 0
    }
    
    func applyChanges() {
        print("적용하기 tapped")
    }
    
    func handleBackTap() {
        print("뒤로가기 tapped")
    }
}
