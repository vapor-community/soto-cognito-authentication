// swift-tools-version:5.10
//===----------------------------------------------------------------------===//
//
// This source file is part of the Soto for AWS open source project
//
// Copyright (c) 2020-2021 the Soto project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Soto project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "soto-cognito-authentication",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "SotoCognitoAuthentication", targets: ["SotoCognitoAuthentication"]),
    ],
    dependencies: [
        .package(url: "https://github.com/soto-project/soto-cognito-authentication-kit.git", from: "5.0.0-rc.3"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "SotoCognitoAuthentication", dependencies: [
            .product(name: "SotoCognitoAuthenticationKit", package: "soto-cognito-authentication-kit"),
            .product(name: "Vapor", package: "vapor"),
        ]),
    ]
)
