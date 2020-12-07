// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "soto-cognito-authentication",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "SotoCognitoAuthentication", targets: ["SotoCognitoAuthentication"]),
    ],
    dependencies: [
        .package(name: "soto-cognito-authentication-kit", url: "https://github.com/adam-fowler/aws-cognito-authentication-kit.git", .branch("soto-v5")),
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(name: "SotoCognitoAuthentication", dependencies: [
            .product(name: "SotoCognitoAuthenticationKit", package: "soto-cognito-authentication-kit"),
            .product(name: "Vapor", package: "vapor")
        ])
    ]
)
