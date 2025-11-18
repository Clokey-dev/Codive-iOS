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
    case editCategory
    case codiBoard
    case search
    case alarm
    
    // MARK: - 하단 탭바
    /// 이 화면이 탭바를 덮어야 하는가?
    /// - 전체 화면으로 표시되어야 하는 플로우는 true 반환
    /// - 기본적으로 탭바는 표시됨 (false)
    var shouldCoverTabBar: Bool {
        switch self {
        // Add Flow - 기록 추가 관련 전체 화면
        case .recordAdd, .photoEdit, .recordDetail, .photoTag:
            return true
        
        // Home Flow
        case .editCategory, .codiBoard:
            return true
            
        // Search, Alarm Flow
        case .search, .alarm:
            return true
            
        // 다른 플로우 전체 화면은 여기에 추가
        // case .closetEdit, .feedCreate:
        //     return true
            
        default:
            return false
        }
    }
}
