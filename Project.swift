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
            sources: ["Clokey/Sources/**"],
            resources: ["Clokey/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "ClokeyTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.ClokeyTests",
            infoPlist: .default,
            sources: ["Clokey/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Clokey")]
        ),
    ]
)
