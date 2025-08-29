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

let project = Project(
    name: "Clokey",
    targets: [
        .target(
            name: "Clokey",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Clokey",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
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
                    ]
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
            dependencies: []
        ),
    ]
)
