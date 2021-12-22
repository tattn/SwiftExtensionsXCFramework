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
        url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/3.0.0-beta.0/SwiftExtensions.xcframework.zip",
        checksum: "d8dfc34cca2fd400b72306913e016e4e68518137258505a67b00d109e3595244"
    ),
    .binaryTarget(
        name: "SwiftExtensionsUI",
        url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/3.0.0-beta.0/SwiftExtensionsUI.xcframework.zip",
        checksum: "172479be27f98ed2e561347030fa20fafb4235c5daccc7cbd28a858b6c03a3d2"
    ),
    .binaryTarget(
        name: "SwiftExtensionsUIKit",
        url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/3.0.0-beta.0/SwiftExtensionsUIKit.xcframework.zip",
        checksum: "608ac79dc9bb3dad96e284343bde9f1a419107b2d3bf3d59fefb09abf3dd8988"
    ),
]

package.products = package.targets
    .filter { !$0.isTest }
    .map { Product.library(name: $0.name, targets: [$0.name]) }
