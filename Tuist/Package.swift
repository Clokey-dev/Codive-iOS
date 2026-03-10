// swift-tools-version: 5.9
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
            "Kingfisher": .framework,
            "FirebaseAnalytics": .framework,
        ]
    )
#endif

let package = Package(
    name: "Codive",
    dependencies: [
        // 카카오 SDK
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.22.5"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/Clokey-dev/CodiveAPI", branch: "main"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", exact: "1.1.4"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.9.1"),
        .package(url: "https://github.com/apple/swift-protobuf.git", exact: "1.28.1"),
    ]
)
