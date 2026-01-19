//
//  FollowListMode.swift
//  Codive
//
//  Created by 한태빈 on 1/13/26.
import Foundation

enum FollowListMode: Hashable {
    case followers
    case followings

    var title: String {
        switch self {
        case .followers: return "팔로워"
        case .followings: return "팔로잉"
        }
    }
}
