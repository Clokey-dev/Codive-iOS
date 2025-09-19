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
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon-Dev",
            "BASE_URL": "https://dev-api.clokey.com"
        ],
        xcconfig: nil
    ),
    .release(
        name: "Release",
        settings: [
            "PRODUCT_NAME": "Codive",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
            "BASE_URL": "https://api.clokey.com"
        ],
        xcconfig: nil
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
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [:],
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
                    "BASE_URL": "$(BASE_URL)"
                ]
            ),
            sources: [
                "Codive/Application/**",
                "Codive/Core/**",
                "Codive/Data/**",
                "Codive/Domain/**",
                "Codive/Presentation/**"
            ],
            resources: ["Codive/Resources/**"],
            scripts: [lintScript],
            dependencies: [],
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
