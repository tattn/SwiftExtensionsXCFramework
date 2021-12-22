// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SwiftExtensions",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ]
)

package.targets = [
    .binaryTarget(
        name: "SwiftExtensions",
        url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/3.0.0-beta.1/SwiftExtensions.xcframework.zip",
        checksum: "716cefb72bee2faef7a70f631ff890cf27ecdb235f04b3d45408e4975af26f3e"
    ),
    .binaryTarget(
        name: "SwiftExtensionsUI",
        url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/3.0.0-beta.1/SwiftExtensionsUI.xcframework.zip",
        checksum: "df8e68631e0bbd47cb2d166cefb765bc50b92e44030e22c7b41b9b65cc9b6d31"
    ),
    .binaryTarget(
        name: "SwiftExtensionsUIKit",
        url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/3.0.0-beta.1/SwiftExtensionsUIKit.xcframework.zip",
        checksum: "873a8114dc38e6402fbf1c51e90a06540d21cb660dbf71e20b7dbc8e817c106b"
    ),
]

package.products = package.targets
    .filter { !$0.isTest }
    .map { Product.library(name: $0.name, targets: [$0.name]) }
