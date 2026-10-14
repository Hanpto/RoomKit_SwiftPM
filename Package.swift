// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TUIRoomKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "TUIRoomKit", targets: ["TUIRoomKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/Hanpto/AtomicXCoreAtomic_SwiftPM.git", from: "5.2.1"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1")
    ],
    targets: [
        .target(
            name: "TUIRoomKit",
            dependencies: [
                .product(name: "AtomicXCore", package: "AtomicXCoreAtomic_SwiftPM"),
                .product(name: "SnapKit", package: "SnapKit")
            ],
            path: "Sources",
            exclude: ["TUIRoomKit.podspec", "README.md"],
            resources: [.process("Resources/TUIRoomKitIcons.xcassets"), .process("Resources/en.lproj"), .process("Resources/zh-Hans.lproj")]
        )
    ],
    swiftLanguageModes: [.v5]
)
