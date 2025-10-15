// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SiopOpenID4VP",
  platforms: [.iOS(.v14), .macOS(.v12)],
  products: [
    .library(
      name: "SiopOpenID4VP",
      targets: ["SiopOpenID4VP"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/airsidemobile/JOSESwift.git",
      from: "3.0.0"
    ),
    .package(
      url: "https://github.com/apple/swift-certificates.git",
      .upToNextMajor(from: "1.15.0")
    ),
    .package(
      url: "https://github.com/apple/swift-asn1.git",
      .upToNextMajor(from: "1.5.0")
    ),
    .package(
      url: "https://github.com/niscy-eudiw/BlueECC.git",
      .upToNextMajor(from: "1.2.4")
    ),
    .package(
      url: "https://github.com/krzyzanowskim/CryptoSwift.git",
      from: "1.8.4"
    ),
    .package(
      url: "https://github.com/SwiftyJSON/SwiftyJSON.git",
      from: "5.0.1"
    ),
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
          name: "X509",
          package: "swift-certificates"
        ),
        .product(
          name: "SwiftASN1",
          package: "swift-asn1"
        ),
        .product(
          name: "CryptorECC",
          package: "BlueECC"
        ),
        .product(
          name: "SwiftyJSON",
          package: "SwiftyJSON"
        ),
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
          name: "JOSESwift",
          package: "JOSESwift"
        ),
        .product(
          name: "CryptoSwift",
          package: "CryptoSwift"
        ),
        .product(
          name: "SwiftyJSON",
          package: "SwiftyJSON"
        ),
      ],
      path: "Tests"
    )
  ]
)
