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

#if hasFeature(RetroactiveAttribute)
extension CognitoAuthenticateResponse: @retroactive Authenticatable {}
extension CognitoAccessToken: @retroactive Authenticatable {}
#else
extension CognitoAuthenticateResponse: Authenticatable {}
extension CognitoAccessToken: Authenticatable {}
#endif

public typealias CognitoBasicAuthenticatable = CognitoAuthenticateResponse
public typealias CognitoAccessAuthenticatable = CognitoAccessToken

/// Authenticator for Cognito username and password
public struct CognitoBasicAuthenticator: AsyncBasicAuthenticator {
    public init() {}

    public func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        do {
            let token = try await request.application.cognito.authenticatable.authenticate(username: basic.username, password: basic.password, context: request)
            request.auth.login(token)
        } catch {
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
public struct CognitoAccessAuthenticator: AsyncBearerAuthenticator {
    public init() {}

    public func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        do {
            let token = try await request.application.cognito.authenticatable.authenticate(accessToken: bearer.token)
            request.auth.login(token)
        } catch {
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
public struct CognitoIdAuthenticator<Payload: Authenticatable & Codable>: AsyncBearerAuthenticator {
    public init() {}

    public func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        do {
            let payload: Payload = try await request.application.cognito.authenticatable.authenticate(idToken: bearer.token)
            request.auth.login(payload)
        } catch {
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
