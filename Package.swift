// swift-tools-version: 5.6

import Foundation
import PackageDescription

let package = Package(
    name: "NimbusSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(
           name: "NimbusKit",
           targets: ["NimbusTarget"]),
        .library(
           name: "NimbusRenderKit",
           targets: ["NimbusRenderTarget"]),
        .library(
           name: "NimbusRenderStaticKit",
           targets: ["NimbusRenderStaticTarget"]),
        .library(
           name: "NimbusRenderVideoKit",
           targets: ["NimbusRenderVideoTarget"]),
        .library(
           name: "NimbusRequestKit",
           targets: ["NimbusRequestTarget"]),
        .library(
           name: "NimbusGAMKit",
           targets: ["NimbusGAMKit"]),
        .library(
           name: "NimbusAdMobKit",
           targets: ["NimbusAdMobKit"]),
        .library(
           name: "NimbusGoogleKit",
           targets: ["NimbusGoogleKit"]),
        .library(
           name: "NimbusFANKit",
           targets: ["NimbusRenderFANKit", "NimbusRequestFANKit"]),
        .library(
           name: "NimbusLiveRampKit",
           targets: ["NimbusLiveRampKit"]),
        .library(
           name: "NimbusRequestAPSKit",
           targets: ["NimbusRequestAPSKit", "DTBiOSSDK"]),
        .library(
           name: "NimbusUnityKit",
           targets: ["NimbusUnityKit", "UnityAds"]),
        .library(
           name: "NimbusVungleKit",
           targets: ["NimbusVungleKit"]),
        .library(
           name: "NimbusMintegralKit",
           targets: ["NimbusMintegralKit"]),
        .library(
           name: "NimbusMobileFuseKit",
           targets: ["NimbusMobileFuseKit"]),
        .library(
           name: "NimbusMolocoKit",
           targets: ["NimbusMolocoKit"]),
        .library(
           name: "NimbusInMobiKit",
           targets: ["NimbusInMobiKit"]),
        .library(
           name: "NimbusRequestAPSKit-WithoutDTBiOSSDK",
           targets: ["NimbusRequestAPSKit"]),
        .library(
           name: "NimbusFANKit-WithoutFBAudienceNetwork",
           targets: ["NimbusRenderFANKit", "NimbusRequestFANKit"]),
        .library(
           name: "NimbusUnityKit-WithoutUnityAds",
           targets: ["NimbusUnityKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LiveRamp/ats-sdk-ios.git", from: "2.5.0"),
        .package(url: "https://github.com/birdrides/mockingbird.git", from: "0.20.0"),
        .package(url: "https://github.com/Vungle/VungleAdsSDK-SwiftPackageManager.git", from: "7.6.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", "12.0.0"..<"14.0.0"),
        .package(url: "https://github.com/Mintegral-official/MintegralAdSDK-Swift-Package", "7.6.7"..<"9.0.0"),
        .package(url: "https://github.com/mobilefuse/mobilefuse-ios-sdk-spm", from: "1.10.0"),
        .package(url: "https://github.com/facebook/FBAudienceNetwork", from: "6.21.0"),
        .package(url: "https://github.com/moloco/moloco-sdk-ios-spm", from: "4.4.1")
    ],
    targets: [
        .framework(
            name: "NimbusRenderTarget",
            dependencies: ["NimbusCoreKit", "NimbusRenderKit", "OMSDK_Adsbynimbus"]),
        .framework(
            name: "NimbusRequestTarget",
            dependencies: ["NimbusCoreKit", "NimbusRequestKit"]),
        .framework(
            name: "NimbusRenderStaticTarget",
            dependencies: ["NimbusRenderTarget", "NimbusRenderStaticKit"]),
        .framework(
            name: "NimbusRenderVideoTarget",
            dependencies: ["NimbusRenderTarget", "NimbusRenderVideoKit"]),
        .framework(
            name: "NimbusTarget",
            dependencies: [
                "NimbusRequestTarget",
                "NimbusRenderTarget",
                "NimbusRenderStaticTarget",
                "NimbusRenderVideoTarget",
                "NimbusKit"
            ]),
        .target(
            name: "NimbusRenderFANKit",
            dependencies: ["NimbusRenderTarget", .Facebook]),
        .target(
            name: "NimbusRequestFANKit",
            dependencies: ["NimbusRequestTarget", .Facebook]),
        .target(
            name: "NimbusGAMKit",
            dependencies: ["NimbusTarget", .GoogleMobileAds]),
        .target(
            name: "NimbusAdMobKit",
            dependencies: ["NimbusTarget", .GoogleMobileAds]),
        .target(
            name: "NimbusGoogleKit",
            dependencies: ["NimbusTarget", .GoogleMobileAds]),
        .target(
            name: "NimbusLiveRampKit",
            dependencies: ["NimbusRequestTarget", .LiveRamp]),
        .target(
            name: "NimbusRequestAPSKit",
            dependencies: ["NimbusRequestTarget"]),
        .target(
            name: "NimbusUnityKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget"]),
        .target(
            name: "NimbusMintegralKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Mintegral]),
        .target(
            name: "NimbusMobileFuseKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .MobileFuse]),
        .target(
            name: "NimbusMolocoKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Moloco]),
        .target(
            name: "NimbusInMobiKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", "InMobiSDK"]),
        .target(
            name: "NimbusVungleKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Vungle]),
        .binaryTarget(
            name: "OMSDK_Adsbynimbus",
            url: "https://adsbynimbus-public.s3.us-east-1.amazonaws.com/iOS/external/omsdk/1.6.9/OMSDK_Adsbynimbus-1.6.9.zip",
            checksum: "f0a0b6d7316319581154c766127333b1c84a9813ec15095d3b1cef4467692f36"),
        .binaryTarget(
             name: "DTBiOSSDK",
             url: "https://d14jk8f50gmy3e.cloudfront.net/iOS_APS_SDK/APS_iOS_SDK-5.3.3.zip",
             checksum: "8e63092764121356b6e3e56d6f1f4b108ba602fb20b93373a5129d3902f77742"),
        .binaryTarget(
            name: "UnityAds",
            url: "https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.15.1/UnityAds.zip",
            checksum: "14bf337196be779f91f894c6bc919b3394cf599a6c3a2e3da434773906b68a68"),
        .binaryTarget(
            name: "InMobiSDK",
            url: "https://dl.inmobi.com/inmobi-sdk/IM/InMobi-iOS-SDK-10.8.6.zip",
            checksum: "ab0f05cd8aa0a7b1085a2b4f57f06ba27ae5dc310e1d9c1241011bba6ba98949")
    ]
)

extension Target {
    static func framework(name: String, dependencies: [Target.Dependency]) -> Target {
        target(
            name: name,
            dependencies: dependencies,
            path: "Sources/\(name.replacingOccurrences(of: "Target", with: "Kit"))",
            sources: ["Export.swift"])
    }
}

extension Target.Dependency {
    static let LiveRamp = product(name: "LRAtsSDK", package: "ats-sdk-ios")
    static let MockingBird = product(name: "Mockingbird", package: "Mockingbird")
    static let Vungle = product(name: "VungleAdsSDK", package: "VungleAdsSDK-SwiftPackageManager")
    static let GoogleMobileAds = product(
        name: "GoogleMobileAds",
        package: "swift-package-manager-google-mobile-ads"
    )
    static let Mintegral = product(
        name: "MintegralAdSDK",
        package: "MintegralAdSDK-Swift-Package"
    )
    static let MobileFuse = product(name: "MobileFuseSDK", package: "mobilefuse-ios-sdk-spm")
    static let Facebook = product(name: "FBAudienceNetwork", package: "FBAudienceNetwork")
    static let Moloco = product(name: "MolocoSDK", package: "moloco-sdk-ios-spm")
}

package.targets += [
    .binaryTarget(
        name: "NimbusCoreKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.34.1/NimbusCoreKit-2.34.1.zip",
        checksum: "5f6e792435473d51ecf859f813c93bcb35b1051ef2348d4e77fb6d7461e00644"),
    .binaryTarget(
        name: "NimbusKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.34.1/NimbusKit-2.34.1.zip",
        checksum: "730f503c8341761bd1a6d870dcd8ab386a239e4f3b080e5bee8ee98b2e03160c"),
    .binaryTarget(
        name: "NimbusRequestKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.34.1/NimbusRequestKit-2.34.1.zip",
        checksum: "87acadfc632c993d3d2a1fb1e0cb67f644207329b76d14c02d3ac81754b71ed5"),
    .binaryTarget(
        name: "NimbusRenderKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.34.1/NimbusRenderKit-2.34.1.zip",
        checksum: "250db61c491167406d2009372759cc49e2bede6cf60c59ddc0a7a7bb0f858ce4"),
    .binaryTarget(
        name: "NimbusRenderStaticKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.34.1/NimbusRenderStaticKit-2.34.1.zip",
        checksum: "538dc8abb0a96c6f02069869c5d3eb5081c14f1b22526f7d68828578dc74c3ed"),
    .binaryTarget(
        name: "NimbusRenderVideoKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.34.1/NimbusRenderVideoKit-2.34.1.zip",
        checksum: "561c52faa3c221ff5ceddc3258e1b6909454da111c4889621bd1a223c39f7161"),
]