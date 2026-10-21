// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TFYSwiftBannerScrollKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TFYSwiftBannerScrollKit", targets: ["TFYSwiftBannerScrollKit"])
    ],
    targets: [
        .target(
            name: "TFYSwiftBannerScrollKit",
            path: "TFYSwiftBannerScroll/TFYSwiftBannerScrollKit"
        ),
        .testTarget(
            name: "TFYSwiftBannerScrollKitTests",
            dependencies: ["TFYSwiftBannerScrollKit"],
            path: "TFYSwiftBannerScrollTests",
            exclude: ["Info.plist"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
