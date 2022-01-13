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

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Request.SotoCognito {
    /// helper function that returns if request with bearer token is cognito access authenticated
    /// - returns:
    ///     An access token object that contains the user name and id
    public func authenticateAccess() async throws -> CognitoAccessToken {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        return try await request.application.cognito.authenticatable.authenticate(accessToken: bearer.token, on: request.eventLoop)
    }

    /// helper function that returns if request with bearer token is cognito id authenticated and returns contents in the payload type
    /// - returns:
    ///     The payload contained in the token. See `authenticate<Payload: Codable>(idToken:on:)` for more details
    public func authenticateId<Payload: Codable>() async throws -> Payload {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        return try await request.application.cognito.authenticatable.authenticate(idToken: bearer.token, on: request.eventLoop)
    }

    /// helper function that returns refreshed access and id tokens given a request containing the refresh token as a  bearer token
    /// - returns:
    ///     The payload contained in the token. See `authenticate<Payload: Codable>(idToken:on:)` for more details
    public func refresh(username: String) async throws -> CognitoAuthenticateResponse {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        return try await request.application.cognito.authenticatable.refresh(
            username: username,
            refreshToken: bearer.token,
            context: request,
            on: request.eventLoop
        )
    }

    /// helper function that returns AWS credentials for a provided identity. The idToken is provided as a bearer token.
    /// If you have setup to use an AWSCognito User pool to identify users then the idToken is the idToken returned from the `authenticate` function
    /// - returns:
    ///     AWS credentials for signing request to AWS
    public func awsCredentials() async throws -> CognitoIdentity.Credentials {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        let identifiable = request.application.cognito.identifiable
        let identity = try await identifiable.getIdentityId(idToken: bearer.token, on: request.eventLoop)
        return try await identifiable.getCredentialForIdentity(identityId: identity, idToken: bearer.token, on: self.request.eventLoop)
    }
}

#endif // compiler(>=5.5) && canImport(_Concurrency)
