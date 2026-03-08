//
//  SearchEntity.swift
//  Codive
//
//  Created by 한금준 on 11/14/25.
//

import Foundation

struct PostEntity: Identifiable {
    let id: Int
    let postImageUrl: String?
    let profileImageUrl: String?
    let nickname: String
    let likes: Int
    let date: Date
    let description: String?
}

struct SortOptionEntity: Identifiable, Hashable {
    let id: String
    let displayName: String
}

/// 서버 연결 용 entity

struct SearchRecommendationEntity: Identifiable {
    let historyId: Int64
    let memberId: Int64
    let recommendType: String
    let title: String
    let subTitle: String
    let imageUrl: String
    
    var id: Int64 { historyId }
}

struct SearchMembersEntity {
    let memberId: Int64
    let profileImageUrl: String
    let nickname: String
}

struct SearchHistoriesEntity {
    let historyId: Int64
    let historyImageUrl: String
    let profileImageUrl: String
    let nickname: String
}
