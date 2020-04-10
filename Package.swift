// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aws-cognito-authentication",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "AWSCognitoAuthentication", targets: ["AWSCognitoAuthentication"]),
    ],
    dependencies: [
        .package(url: "https://github.com/adam-fowler/aws-cognito-authentication-kit.git", .upToNextMajor(from: "1.0.0-beta")),
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(name: "AWSCognitoAuthentication", dependencies: ["AWSCognitoAuthenticationKit", "Vapor"])
    ]
)
