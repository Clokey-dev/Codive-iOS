//
//  AppConfigurator.swift
//  Codive
//
//  Created by 황상환 on 9/21/25.
//

import Foundation
import KakaoSDKCommon
import Kingfisher
import FirebaseCore
import FirebaseCrashlytics

final class AppConfigurator {

    static func configure() {
        configureFirebase()
        configureKakaoSDK()
        configureImageCache()
    }

    private static func configureFirebase() {
        FirebaseApp.configure()

        #if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #endif
    }

    private static func configureImageCache() {
        let cache = ImageCache.default
        // 메모리 캐시 100MB 제한
        cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
        // 메모리 캐시 항목 수 150개 제한
        cache.memoryStorage.config.countLimit = 150
    }
    
    private static func configureKakaoSDK() {
        guard let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String else {
            #if DEBUG
            print("[App] KAKAO_APP_KEY not found in Info.plist")
            #endif
            return
        }

        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }
}
