//
//  AppDestination.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation

enum AppDestination: Hashable {
    case login
    case signup
    case main
    
    // 각 목적지의 고유 식별자
    var id: String {
        switch self {
        case .login:
            return "login"
        case .signup:
            return "signup"
        case .main:
            return "main"
        }
    }
}
