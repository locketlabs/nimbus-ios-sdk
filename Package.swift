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
           name: "NimbusAdMobKit",
           targets: ["NimbusAdMobKit"]),
        .library(
           name: "NimbusVungleKit",
           targets: ["NimbusVungleKit"]),
        .library(
           name: "NimbusMolocoKit",
           targets: ["NimbusMolocoKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/birdrides/mockingbird.git", from: "0.20.0"),
        .package(url: "https://github.com/Vungle/VungleAdsSDK-SwiftPackageManager.git", from: "7.6.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", "12.0.0"..<"14.0.0"),
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
            name: "NimbusAdMobKit",
            dependencies: ["NimbusTarget", .GoogleMobileAds]),
        .target(
            name: "NimbusMolocoKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Moloco]),
        .testTarget(
            name: "NimbusMolocoKitTests",
            dependencies: ["NimbusMolocoKit"]),
        .target(
            name: "NimbusVungleKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Vungle]),
        .binaryTarget(
            name: "OMSDK_Adsbynimbus",
            url: "https://adsbynimbus-public.s3.us-east-1.amazonaws.com/iOS/external/omsdk/1.6.9/OMSDK_Adsbynimbus-1.6.9.zip",
            checksum: "f0a0b6d7316319581154c766127333b1c84a9813ec15095d3b1cef4467692f36"),
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
    static let MockingBird = product(name: "Mockingbird", package: "Mockingbird")
    static let Vungle = product(name: "VungleAdsSDK", package: "VungleAdsSDK-SwiftPackageManager")
    static let GoogleMobileAds = product(
        name: "GoogleMobileAds",
        package: "swift-package-manager-google-mobile-ads"
    )
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
