import ProjectDescription

let project = Project(
    name: "Clokey",
    targets: [
        .target(
            name: "Clokey",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Clokey",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
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
            dependencies: []
        ),
    ]
)
