import ProjectDescription

// MARK: - Projects

// SwiftLint 스크립트 정의
let lintScript = TargetScript.pre(
    script: """
    if test -d "/opt/homebrew/bin/"; then
        PATH="/opt/homebrew/bin/:${PATH}"
    fi

    if which swiftlint > /dev/null; then
        swiftlint
    else
        echo "warning: SwiftLint not installed, skipping..."
    fi
    """,
    name: "SwiftLint",
    basedOnDependencyAnalysis: false
)

// MARK: - Configurations

// Debug와 Release 설정을 정의합니다.
let configurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: [
            "PRODUCT_NAME": "Codive (Dev)",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": ["DEBUG"],
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon-Dev"
        ],
        xcconfig: "Codive/Resources/Secrets/Debug.xcconfig"
    ),
    .release(
        name: "Release",
        settings: [
            "PRODUCT_NAME": "Codive",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon"
        ],
        xcconfig: "Codive/Resources/Secrets/Release.xcconfig"
    )
]

// MARK: - Settings

let projectSettings = Settings.settings(
    base: [:],
    configurations: configurations,
    defaultSettings: .recommended
)

// MARK: - Project

let project = Project(
    name: "Codive",
    settings: projectSettings,
    targets: [
        .target(
            name: "Codive",
            destinations: .iOS,
            product: .app,
            bundleId: "com.codive.app",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [:],
                    "CFBundleDevelopmentRegion": "ko",
                    "CFBundleLocalizations": ["ko", "en"],
                    "UIAppFonts": [
                        "Pretendard-Black.otf",
                        "Pretendard-Bold.otf",
                        "Pretendard-ExtraBold.otf",
                        "Pretendard-ExtraLight.otf",
                        "Pretendard-Light.otf",
                        "Pretendard-Medium.otf",
                        "Pretendard-Regular.otf",
                        "Pretendard-SemiBold.otf",
                        "Pretendard-Thin.otf"
                    ],
                    "CFBundleDisplayName": "$(PRODUCT_NAME)",
                    "BASE_URL": "$(BASE_URL)",
                    
                    // 갤러리 & 카메라 권한 추가
                    "NSPhotoLibraryUsageDescription": "기록을 추가하기 위해 사진 접근 권한이 필요합니다.",
                    "NSPhotoLibraryAddUsageDescription": "사진을 저장하기 위해 권한이 필요합니다.",
                    "NSCameraUsageDescription": "사진을 촬영하기 위해 카메라 권한이 필요합니다.",
                    
                    // 카카오 SDK 설정
                    "KAKAO_APP_KEY": "$(KAKAO_APP_KEY)",
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLName": "KAKAO",
                            "CFBundleURLSchemes": ["kakao$(KAKAO_APP_KEY)"]
                        ]
                    ],
                    "LSApplicationQueriesSchemes": [
                        "kakaokompassauth",
                        "storykompassauth",
                        "kakaolink",
                        "kakaotalk-5.9.7"
                    ]
                ]
            ),
            sources: [
                "Codive/Application/**",
                "Codive/Core/**",
                "Codive/DIContainer/**",
                "Codive/Features/**",
                "Codive/Router/**",
                "Codive/Shared/**",
            ],
            resources: ["Codive/Resources/**"],
            entitlements: .file(path: "Codive/Codive.entitlements"),
            scripts: [lintScript],
            dependencies: [
                // 카카오 SDK
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
                
                // 네트워킹
                .external(name: "Moya"),
                
                // 이미지 크롭
                .external(name: "SwiftyCrop"),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "BBVZV8T99P",
                    "CODE_SIGN_STYLE": "Manual"
                ],
                configurations: [
                    .debug(name: "Debug", settings: [
                        "PROVISIONING_PROFILE_SPECIFIER": "match Development com.codive.app",
                        "CODE_SIGN_IDENTITY": "Apple Development"
                    ]),
                    .release(name: "Release", settings: [
                        "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.codive.app",
                        "CODE_SIGN_IDENTITY": "Apple Distribution"
                    ])
                ]
            )
        ),
    ]
)
