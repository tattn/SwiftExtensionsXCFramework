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
    ],
)

package.targets = package.targets + [
	.binaryTarget(
		name: "SwiftExtensions",
		url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/3.0.0-beta.0/SwiftExtensions.xcframework.zip",
		checksum: "a9afd45143f04602921b2c3242d29430a167c12bbd7d3a7469da71dead98cc27"
	),
	.binaryTarget(
		name: "SwiftExtensionsUI",
		url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/3.0.0-beta.0/SwiftExtensionsUI.xcframework.zip",
		checksum: "b3e908db091d1be894ec1ad47ef2e6e421a76e7fb85eea04ff68c48065e54934"
	),
	.binaryTarget(
		name: "SwiftExtensionsUIKit",
		url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/3.0.0-beta.0/SwiftExtensionsUIKit.xcframework.zip",
		checksum: "72f302a91d4ad575c81e20d1742ffe77857b7aa482524cce418cb7b2e78a0645"
	),
]

package.products = package.targets
    .filter { !$0.isTest }
    .map { Product.library(name: $0.name, targets: [$0.name]) }
