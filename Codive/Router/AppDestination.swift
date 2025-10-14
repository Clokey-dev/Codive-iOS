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
    case recordAdd
    case photoEdit(photos: [SelectedPhoto])
    case recordDetail(photos: [SelectedPhoto])
    case photoTag(photo: SelectedPhoto, allPhotos: [SelectedPhoto])

    // MARK: - Computed Properties
    
    /// 각 목적지의 고유 식별자
    var id: String {
        switch self {
        case .login:
            return "login"
        case .signup:
            return "signup"
        case .main:
            return "main"
        case .recordAdd:
            return "recordAdd"
        case .photoEdit:
            return "photoEdit"
        case .recordDetail(photos: _):
            return "photoEdit"
        case .photoTag(photo: _, allPhotos: _):
            return "photoTag"
        }
    }
    
    /// 이 화면이 탭바를 덮어야 하는가?
    var shouldCoverTabBar: Bool {
        switch self {
        case .recordAdd, .photoEdit, .recordDetail, .photoTag:
            return true
        default:
            return false
        }
    }
}
