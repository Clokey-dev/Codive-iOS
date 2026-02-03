//
//  SearchDTO.swift
//  Codive
//
//  Created by 한금준 on 1/27/26.
//

import Foundation

/// 검색 탭 기록 추천
struct SearchRecommendationResponseDTO {
    let historyId: Int64
    let memberId: Int64
    let recommendType: String
    let title: String
    let subTitle: String
    let imageUrl: String
    
    func toEntity() -> SearchRecommendationEntity {
        return SearchRecommendationEntity(
            historyId: historyId,
            memberId: memberId,
            recommendType: recommendType,
            title: title,
            subTitle: subTitle,
            imageUrl: imageUrl
        )
    }
}

/// 유저 검색
struct SearchUserResponseDTO {
    let content : [SearchUserResponseItem]
    let isLast: Bool
}

struct SearchUserResponseItem {
    let memberId: Int64
    let profileImageUrl: String
    let nickname: String
    
    func toEntity() -> SearchMembersEntity {
        return SearchMembersEntity(
            memberId: memberId,
            profileImageUrl: profileImageUrl,
            nickname: nickname
        )
    }
}

/// 기록 검색
struct SearchHistoryResponseDTO {
    let content: [SearchHistoryResponseItem]
    let isLast: Bool
}

struct SearchHistoryResponseItem {
    let historyId: Int64
    let historyImageUrl: String
    let profileImageUrl: String
    let nickname: String
    
    
    func toEntity() -> SearchHistoriesEntity {
        return SearchHistoriesEntity(
            historyId: historyId,
            historyImageUrl: historyImageUrl,
            profileImageUrl: profileImageUrl,
            nickname: nickname
        )
    }
}
