// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
            "KakaoSDKUser": .framework,
            "KakaoSDKAuth": .framework,
            "KakaoSDKCommon": .framework,
            "Alamofire": .framework,
        ]
    )
#endif

let package = Package(
    name: "Codive",
    dependencies: [
        // 카카오 SDK
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.22.5"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/Clokey-dev/CodiveAPI", branch: "main")
    ]
)
