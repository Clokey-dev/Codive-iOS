//
//  SearchEntity.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import Foundation

struct SearchEntity {
}

struct SearchTagEntity: Identifiable {
    let id: Int
    let text: String
}

struct NewsEntity: Identifiable {
    let id: Int
    let imageUrl: String
    let title: String
}
