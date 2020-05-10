// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aws-cognito-authentication",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "AWSCognitoAuthentication", targets: ["AWSCognitoAuthentication"]),
    ],
    dependencies: [
        .package(url: "https://github.com/adam-fowler/aws-cognito-authentication-kit.git", .branch("aws-sdk-swift-master")),
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(name: "AWSCognitoAuthentication", dependencies: [
            .product(name: "AWSCognitoAuthenticationKit", package: "aws-cognito-authentication-kit"),
            .product(name: "Vapor", package: "vapor")
        ])
    ]
)
