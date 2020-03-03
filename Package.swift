// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AWSCognitoAuthentication",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "AWSCognitoAuthenticationKit", targets: ["AWSCognitoAuthenticationKit"]),
        .library(name: "AWSCognitoAuthentication", targets: ["AWSCognitoAuthentication"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/swift-server/async-http-client.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/swift-aws/aws-sdk-swift.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0-rc.1")),
        .package(url: "https://github.com/vapor/jwt-kit.git", .upToNextMajor(from: "4.0.0-rc.1")),
        // for SRP
        .package(url: "https://github.com/adam-fowler/big-num.git", .upToNextMajor(from: "1.1.0")),
    ],
    targets: [
        .target(name: "AWSCognitoAuthentication",
            dependencies: [
                .target(name: "AWSCognitoAuthenticationKit"),
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .target(name: "AWSCognitoAuthenticationKit",
                dependencies: [
                    .product(name: "AsyncHTTPClient", package: "async-http-client"),
                    .product(name: "BigNum", package: "big-num"),
                    .product(name: "CognitoIdentity", package: "aws-sdk-swift"),
                    .product(name: "CognitoIdentityProvider", package: "aws-sdk-swift"),
                    .product(name: "JWTKit", package: "jwt-kit"),
                    .product(name: "Crypto", package: "swift-crypto")
            ]
        ),
        .testTarget(name: "AWSCognitoAuthenticationKitTests", dependencies: [.target(name: "AWSCognitoAuthenticationKit")]),
    ]
)
