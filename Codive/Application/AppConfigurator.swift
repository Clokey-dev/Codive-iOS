//
//  AppConfigurator.swift
//  Codive
//
//  Created by 황상환 on 9/21/25.
//

import Foundation
import KakaoSDKCommon

final class AppConfigurator {
    
    static func configure() {
        configureKakaoSDK()
    }
    
    private static func configureKakaoSDK() {
        guard let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String else {
            print("KAKAO_APP_KEY not found in Info.plist")
            return
        }
        
        KakaoSDK.initSDK(appKey: kakaoAppKey)
        print("Kakao SDK initialized")
    }
}
