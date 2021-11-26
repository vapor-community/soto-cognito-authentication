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

#if compiler(>=5.5) && canImport(_Concurrency)

import NIO
import Vapor

/// Async Authenticator for Cognito username and password
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public struct AsyncCognitoBasicAuthenticator: AsyncBasicAuthenticator {
    public init() {}
    
    public func authenticate(basic: BasicAuthorization, for request: Request) async throws  {
        do {
            let token = try await request.application.cognito.authenticatable.authenticate(
                username: basic.username,
                password: basic.password,
                context: request,
                on:request.eventLoop
            )
            request.auth.login(token)
        } catch let error as AWSErrorType {
            throw error
        } catch let error as NIOConnectionError {
            throw error
        } catch {
        }
    }
}

/// Async Authenticator for Cognito access tokens
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public struct AsyncCognitoAccessAuthenticator: AsyncBearerAuthenticator {
    public init() {}

    public func authenticate(bearer: BearerAuthorization, for request: Request) async throws  {
        do {
            let token = try await request.application.cognito.authenticatable.authenticate(
                accessToken: bearer.token,
                on:request.eventLoop
            )
            request.auth.login(token)
        } catch let error as NIOConnectionError {
            throw error
        } catch {
        }
    }
}

/// Async Authenticator for Cognito id tokens. Can use this to extract information from Id Token into Payload struct. The list of standard list of claims found in an id token are
/// detailed in the [OpenID spec] (https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims) . Your `Payload` type needs
/// to decode using these tags, plus the AWS specific "cognito:username" tag and any custom tags you have setup for the user pool.
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public struct AsyncCognitoIdAuthenticator<Payload: Authenticatable & Codable>: AsyncBearerAuthenticator {
    public init() {}
    public func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        do {
            let payload: Payload = try await request.application.cognito.authenticatable.authenticate(
                idToken: bearer.token,
                on: request.eventLoop
            )
            request.auth.login(payload)
        } catch let error as NIOConnectionError {
            throw error
        } catch {
        }
    }

}

#endif // compiler(>=5.5) && canImport(_Concurrency)
