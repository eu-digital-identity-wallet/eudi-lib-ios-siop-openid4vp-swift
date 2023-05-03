// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "logic_core",
  platforms: [.iOS(.v14), .macOS(.v12)],
  products: [
    .library(
      name: "logic_core",
      targets: ["logic_core"]),
    ],
    dependencies: [
      .package(
        url: "https://github.com/realm/SwiftLint.git",
        .upToNextMinor(from: "0.51.0")
      ),
    ],
    targets: [
      .target(
        name: "logic_core",
        dependencies: [],
        plugins: [
          .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
        ]),
    ]
)
