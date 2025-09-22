//
//  TabBarType.swift
//  Codive
//
//  Created by 황상환 on 9/22/25.
//

import Foundation

enum TabBarType: String, CaseIterable {
    case home = "home"
    case closet = "clo"
    case feed = "feed"
    case profile = "profile"
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .closet:
            return "옷장"
        case .feed:
            return "피드"
        case .profile:
            return "마이페이지"
        }
    }
    
    var iconName: String {
        return self.rawValue
    }
}
