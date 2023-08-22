// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SiopOpenID4VP",
  platforms: [.iOS(.v14), .macOS(.v12)],
  products: [
    .library(
      name: "SiopOpenID4VP",
      targets: ["SiopOpenID4VP"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/niscy-eudiw/JOSESwift.git",
      .upToNextMinor(from: "2.4.1")
    ),
    .package(
      url: "https://github.com/birdrides/mockingbird.git",
      .upToNextMinor(from: "0.20.0")
    ),
    .package(
      url: "https://github.com/niscy-eudiw/eudi-lib-ios-presentation-exchange-swift.git",
      .upToNextMinor(from: "0.0.26")
    )
  ],
  targets: [
    .target(
      name: "SiopOpenID4VP",
      dependencies: [
        .product(
          name: "JOSESwift",
          package: "JOSESwift"
        ),
        .product(
          name: "PresentationExchange",
          package: "eudi-lib-ios-presentation-exchange-swift"
        )
      ],
      path: "Sources",
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "SiopOpenID4VPTests",
      dependencies: [
        "SiopOpenID4VP",
        .product(
          name: "Mockingbird",
          package: "mockingbird"
        ),
        .product(
          name: "JOSESwift",
          package: "JOSESwift"
        ),
        .product(
          name: "PresentationExchange",
          package: "eudi-lib-ios-presentation-exchange-swift",
          moduleAliases: ["SwiftLintPlugin": "DepSwiftLintPlugin"]
        )
      ],
      path: "Tests"
    ),
  ]
)
