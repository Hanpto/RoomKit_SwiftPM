// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TUIRoomKit",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "TUIRoomKit", targets: ["TUIRoomKit", "TUIRoomKitObjC"])
    ],
    dependencies: [
        .package(url: "https://github.com/Tencent-RTC/AtomicX_SwiftPM.git", from: "4.2.2"),
        .package(url: "https://github.com/Tencent-RTC/AtomicXCore_SwiftPM.git", from: "4.3.0"),
        .package(url: "https://github.com/Tencent-RTC/RTCRoomEngine_SwiftPM.git", from: "4.3.0"),
        .package(url: "https://github.com/Tencent-RTC/TUICore_SwiftPM.git", from: "9.0.7652"),
        .package(url: "https://github.com/Tencent-RTC/Chat_SDK_SwiftPM.git", from: "9.0.7652"),
        .package(url: "https://github.com/Hanpto/ChatKit_SwiftPM.git", from: "1.0.1"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0")
    ],
    targets: [
        .target(
            name: "TUIRoomKit",
            dependencies: [
                .product(name: "AtomicX", package: "AtomicX_SwiftPM"),
                .product(name: "AtomicXCore", package: "AtomicXCore_SwiftPM"),
                .product(name: "RoomEngine", package: "RTCRoomEngine_SwiftPM"),
                .product(name: "TUICore_SwiftPM", package: "TUICore_SwiftPM"),
                .product(name: "Chat_SDK_SwiftPM", package: "Chat_SDK_SwiftPM"),
                .product(name: "TUIChatKit", package: "ChatKit_SwiftPM"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                "TUIRoomKitObjC"
            ],
            path: "Sources",
            exclude: ["TUIRoomKitObjC"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "TUIRoomKitObjC",
            path: "Sources/TUIRoomKitObjC",
            publicHeadersPath: "."
        )
    ],
    swiftLanguageModes: [.v5]
)
