//
//  AppDestination.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import Foundation

enum AppDestination: Hashable, Identifiable {
    case login
    case signup
    case termsAgreement
    case main
    case recordAdd
    case clothPhotoSelect
    case clothAdd(photos: [SelectedPhoto], isAIEnabled: Bool = false)
    case photoEdit(photos: [SelectedPhoto])
    case photoEditForCloth(photos: [SelectedPhoto], isAIEnabled: Bool = false)
    case recordDetail(photos: [SelectedPhoto])
    case recordEdit(feed: Feed)
    case photoTag(photo: SelectedPhoto, allPhotos: [SelectedPhoto])
    case settings
    case settingLikedRecords
    case settingMyComments
    case settingBlockedUsers
    case settingWithdraw
    case report(target: ReportTarget, commentInfo: CommentReportInfo? = nil)
    case reportDetail(target: ReportTarget, commentInfo: CommentReportInfo? = nil)
    case editCategory
    case codiBoard
    case search
    case searchResult(query: String)
    case recentlySearchResult
    case notification
    case lookbook
    case specificLookbook(lookbookId: Int64, name: String)
    case addCodi(lookBookId: Int64)
    case editCodi(selectedCodiData: SelectedCodi)
    case addCodiDetail
    case addBeforeCodi(lookbookId: Int64)
    case codiDetail(codiId: Int)
    case feedDetail(feedId: Int)
    case comment(feedId: Int)
    case favoriteCodiList(showHeart: Bool)
    case followList(mode: FollowListMode, memberId: Int, isMe: Bool)
    case otherProfile(userId: Int)
    case myProfile

    case myCloset
    case clothDetail(cloth: Cloth)
    case clothEdit(cloth: Cloth)
    case wardrobeReport
    case eraserEditor(photo: SelectedPhoto, photoIndex: Int)
    case eraserPreview(photoIndex: Int)
    case profileSetting

    var id: Self { self }
    
    // MARK: - UI 제어

    /// 이 화면이 하단 탭바를 덮어야 하는가?
    /// - 전체 화면으로 표시되어야 하는 플로우는 true 반환
    /// - 기본적으로 탭바는 표시됨 (false)
    var shouldCoverTabBar: Bool {
        switch self {
        // Add Flow - 기록 추가 관련 전체 화면
        case .recordAdd, .clothPhotoSelect, .clothAdd, .photoEdit, .photoEditForCloth, .recordDetail, .recordEdit, .photoTag:
            return true

        // Home Flow
        case .editCategory, .codiBoard:
            return true

        // Search, Alarm Flow
        case .search, .searchResult, .recentlySearchResult, .notification:
            return true
            
        // LookBook
        case .lookbook, .specificLookbook, .addCodi, .addCodiDetail, .addBeforeCodi, .codiDetail, .editCodi:
            return true
            
        // Feed Flow
        case .feedDetail, .comment:
            return true

        // Profile Flow
        case .favoriteCodiList, .settings, .followList, .profileSetting, .otherProfile, .myProfile:
            return true

        // Closet Flow - 전체 화면
        case .myCloset, .clothDetail, .clothEdit, .wardrobeReport, .eraserEditor, .eraserPreview:
            return true

        // 다른 플로우 전체 화면은 여기에 추가
        // case .closetEdit, .feedCreate:
        //     return true

        default:
            return false
        }
    }

    /// 이 화면에서 상단 네비게이션 바를 표시해야 하는가?
    /// - false: 상단바 숨김 (전체 화면)
    /// - true: 상단바 표시
    var shouldShowTopBar: Bool {
        switch self {
        // Add Flow - 전체 화면이므로 상단바 숨김
        case .recordAdd, .clothPhotoSelect, .clothAdd, .photoEdit, .photoEditForCloth, .recordDetail, .recordEdit, .photoTag:
            return false

        // Home Flow - 상단바 표시
        case .editCategory, .codiBoard:
            return true

        // Search, Alarm Flow - 자체 네비게이션 바 있음
        case .search, .searchResult, .notification:
            return false

        // Feed Flow - 자체 네비게이션 바 있음
        case .feedDetail, .comment:
            return false

        // Profile Flow - 자체 네비게이션 바 있음
        case .favoriteCodiList, .settings, .followList, .profileSetting, .otherProfile, .myProfile:
            return false

        // Closet Flow - 자체 네비게이션 바 있음
        case .myCloset, .clothDetail, .clothEdit, .wardrobeReport, .eraserEditor, .eraserPreview:
            return false

        default:
            return true
        }
    }
}
