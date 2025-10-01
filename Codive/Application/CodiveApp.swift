//
//  CodiveApp.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI
import KakaoSDKAuth

@main
struct CodiveApp: App {

    let appDIContainer = AppDIContainer()

    init() {
        AppConfigurator.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(appDIContainer: appDIContainer)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
