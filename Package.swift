// swift-tools-version: 5.8
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
      url: "https://github.com/airsidemobile/JOSESwift.git",
      from: "3.0.0"
    ),
    .package(
      url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-presentation-exchange-swift.git",
      .upToNextMajor(from: "0.3.0")
    ),
    .package(
      url: "https://github.com/apple/swift-certificates.git",
      .upToNextMajor(from: "1.0.0")
    ),
    .package(
      url: "https://github.com/apple/swift-asn1.git",
      .upToNextMajor(from: "1.0.0")
    ),.package(
      url: "https://github.com/niscy-eudiw/BlueECC.git",
      .upToNextMajor(from: "1.2.4")
    ),
    .package(
      url: "https://github.com/krzyzanowskim/CryptoSwift.git",
      from: "1.8.4"
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
          name: "PresentationExchange",
          package: "eudi-lib-ios-presentation-exchange-swift"
        ),
        .product(
          name: "CryptoSwift",
          package: "CryptoSwift"
        )
      ],
      path: "Tests"
    ),
  ]
)
