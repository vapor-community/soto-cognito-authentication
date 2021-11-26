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

import Vapor

public extension Application {
    var cognito: SotoCognito {
        .init(application: self)
    }

    struct SotoCognito {
        struct AuthenticatableKey: StorageKey {
            typealias Value = CognitoAuthenticatable
        }

        public var authenticatable: CognitoAuthenticatable {
            get {
                guard let authenticatable = self.application.storage[AuthenticatableKey.self] else {
                    fatalError("AWSCognito authenticatable not setup. Use application.awsCognito.authenticatable = ...")
                }
                return authenticatable
            }
            nonmutating set {
                self.application.storage[AuthenticatableKey.self] = newValue
            }
        }

        struct IdentifiableKey: StorageKey {
            typealias Value = CognitoIdentifiable
        }

        public var identifiable: CognitoIdentifiable {
            get {
                guard let identifiable = self.application.storage[IdentifiableKey.self] else {
                    fatalError("AWSCognito identifiable not setup. Use application.awsCognito.identifiable = ...")
                }
                return identifiable
            }
            nonmutating set {
                self.application.storage[IdentifiableKey.self] = newValue
            }
        }

        let application: Application
    }
}
