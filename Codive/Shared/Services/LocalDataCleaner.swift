//
//  LocalDataCleaner.swift
//  Codive
//
//  Created on 3/2/26.
//

import Foundation
import Kingfisher

/// 로그아웃 및 토큰 만료 시 로컬 캐시 데이터를 일괄 삭제하는 유틸리티
enum LocalDataCleaner {

    static func clearAll() {
        // UserDefaults 캐시 삭제
        UserDefaults.standard.removeObject(forKey: "SavedCategories")
        UserProfileStorage.clear()
        RecentSearchStorage.clear()
        // Kingfisher 이미지 캐시 삭제
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        // URL 캐시 삭제
        URLCache.shared.removeAllCachedResponses()
    }
}
