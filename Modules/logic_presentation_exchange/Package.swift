// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "logic_presentation_exchange",
  platforms: [.iOS(.v14), .macOS(.v12)],
  products: [
    .library(
      name: "logic_presentation_exchange",
      targets: ["logic_presentation_exchange"]),
    ],
    dependencies: [
      .package(
        url: "https://github.com/realm/SwiftLint.git",
        .upToNextMinor(from: "0.51.0")
      ),
      .package(
        name: "logic_core",
        path: "../logic_core"
      ),
    ],
    targets: [
      .target(
        name: "logic_presentation_exchange",
        dependencies: [
          .product(
            name: "logic_core",
            package: "logic_core"
          )
        ],
        plugins: [
          .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
        ])
    ]
)
