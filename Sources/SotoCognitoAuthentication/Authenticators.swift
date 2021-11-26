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

import NIO
import SotoCognitoAuthenticationKit
import Vapor

extension CognitoAuthenticateResponse: Authenticatable {}
extension CognitoAccessToken: Authenticatable {}

public typealias CognitoBasicAuthenticatable = CognitoAuthenticateResponse
public typealias CognitoAccessAuthenticatable = CognitoAccessToken

/// Authenticator for Cognito username and password
public struct CognitoBasicAuthenticator: BasicAuthenticator {
    public init() {}

    public func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<Void> {
        return request.application.cognito.authenticatable.authenticate(username: basic.username, password: basic.password, context: request, on: request.eventLoop).map { token in
            request.auth.login(token)
        }.flatMapErrorThrowing { error in
            switch error {
            case is AWSErrorType, is NIOConnectionError:
                // report connection errors with AWS, or unrecognised AWSErrorTypes
                throw error
            default:
                return
            }
        }
    }
}

/// Authenticator for Cognito access tokens
public struct CognitoAccessAuthenticator: BearerAuthenticator {
    public init() {}

    public func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        return request.application.cognito.authenticatable.authenticate(accessToken: bearer.token, on: request.eventLoop).map { token in
            request.auth.login(token)
        }.flatMapErrorThrowing { error in
            switch error {
            case is NIOConnectionError:
                // loading of jwk may cause a connection error. We should report this
                throw error
            default:
                return
            }
        }
    }
}

/// Authenticator for Cognito id tokens. Can use this to extract information from Id Token into Payload struct. The list of standard list of claims found in an id token are
/// detailed in the [OpenID spec] (https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims) . Your `Payload` type needs
/// to decode using these tags, plus the AWS specific "cognito:username" tag and any custom tags you have setup for the user pool.
public struct CognitoIdAuthenticator<Payload: Authenticatable & Codable>: BearerAuthenticator {
    public init() {}

    public func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        return request.application.cognito.authenticatable.authenticate(idToken: bearer.token, on: request.eventLoop).map { (payload: Payload) -> Void in
            request.auth.login(payload)
        }.flatMapErrorThrowing { error in
            switch error {
            case is NIOConnectionError:
                // loading of jwk may cause a connection error. We should report this
                throw error
            default:
                return
            }
        }
    }
}
