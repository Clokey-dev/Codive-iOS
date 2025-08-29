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
    name: "SwiftLint"
)

// MARK: - Configurations

// Debug와 Release 설정을 정의합니다.
let configurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: [
            "PRODUCT_NAME": "Clokey (Dev)",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": ["DEBUG"],
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon-Dev",
            "BASE_URL": "https://dev-api.clokey.com"
        ],
        xcconfig: nil
    ),
    .release(
        name: "Release",
        settings: [
            "PRODUCT_NAME": "Clokey",
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
    name: "Clokey",
    settings: projectSettings,
    targets: [
        .target(
            name: "Clokey",
            destinations: .iOS,
            product: .app,
            bundleId: "com.clokey.app",
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
                "Clokey/Application/**",
                "Clokey/Core/**",
                "Clokey/Data/**",
                "Clokey/Domain/**",
                "Clokey/Presentation/**"
            ],
            resources: ["Clokey/Resources/**"],
            scripts: [lintScript],
            dependencies: [],
            settings: .settings(base: [
                "PRODUCT_BUNDLE_IDENTIFIER": "com.clokey.app$(BUNDLE_ID_SUFFIX)"
            ], configurations: [
                .debug(name: "Debug", settings: ["BUNDLE_ID_SUFFIX": ".dev"]),
                .release(name: "Release", settings: ["BUNDLE_ID_SUFFIX": ""])
            ])
        ),
    ]
)
