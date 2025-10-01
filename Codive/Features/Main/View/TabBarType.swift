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
    case add = "plus"
    case feed = "feed"
    case profile = "profile"
    
    // MARK: - Computed Properties
    var title: String {
        switch self {
        case .home:
            return TextLiteral.TabBar.home
        case .closet:
            return TextLiteral.TabBar.closet
        case .add:
            return ""
        case .feed:
            return TextLiteral.TabBar.feed
        case .profile:
            return TextLiteral.TabBar.profile
        }
    }
    
    var iconName: String {
        return self.rawValue
    }
}
