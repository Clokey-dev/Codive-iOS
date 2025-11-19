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

struct PostEntity: Identifiable {
    let id: Int
    let postImageUrl: String?
    let profileImageUrl: String?
    let nickname: String
    let likes: Int
    let date: Date
    let description: String?
}
