//
//  CategoryItem.swift
//  Codive
//
//  Created by 황상환 on 10/9/25.
//

import Foundation

struct CategoryItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subcategories: [String]
}
