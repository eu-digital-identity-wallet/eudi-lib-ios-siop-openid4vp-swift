// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenID4VP",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "git@github.com:niscy-eudiw/openid4vp-ios.git",
            targets: ["openid4vp-ios"]),
    ],
    dependencies: [
      .package(
        url: "https://github.com/kylef/JSONSchema.swift",
        from: "0.6.0"
      ),
      .package(
        url: "https://github.com/KittyMac/Sextant.git",
          .upToNextMinor(from: "0.4.0")
      ),
      .package(
        url: "https://github.com/realm/SwiftLint.git",
          .upToNextMinor(from: "0.51.0")
      )
    ],
    targets: [
        .target(
            name: "openid4vp-ios",
            dependencies: [
              .product(
                name: "Sextant",
                package: "Sextant"
              )
            ],
            resources: [
              .process("Resources")
            ],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
        ),
        .testTarget(
            name: "openid4vp-iosTests",
            dependencies: [
              "openid4vp-ios",
              .product(
                name: "JSONSchema",
                package: "JSONSchema.swift"
              ),
              .product(
                name: "Sextant",
                package: "Sextant"
              )
            ]
        ),
    ]
)
