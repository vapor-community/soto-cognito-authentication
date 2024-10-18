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

// extend AWSCognitoAuthenticateResponse so it can be returned from a Vapor route
#if hasFeature(RetroactiveAttribute)
extension CognitoAuthenticateResponse: @retroactive Content {}
#else
extension CognitoAuthenticateResponse: Content {}
#endif

public extension Request {
    var cognito: SotoCognito {
        .init(request: self)
    }

    struct SotoCognito {
        /// helper function that returns if request with bearer token is cognito access authenticated
        /// - returns:
        ///     An access token object that contains the user name and id
        public func authenticateAccess() async throws -> CognitoAccessToken {
            guard let bearer = request.headers.bearerAuthorization else {
                throw Abort(.unauthorized)
            }
            return try await self.request.application.cognito.authenticatable.authenticate(accessToken: bearer.token)
        }

        /// helper function that returns if request with bearer token is cognito id authenticated and returns contents in the payload type
        /// - returns:
        ///     The payload contained in the token. See `authenticate<Payload: Codable>(idToken:on:)` for more details
        public func authenticateId<Payload: Codable & Sendable>() async throws -> Payload {
            guard let bearer = request.headers.bearerAuthorization else {
                throw Abort(.unauthorized)
            }
            return try await self.request.application.cognito.authenticatable.authenticate(idToken: bearer.token)
        }

        /// helper function that returns refreshed access and id tokens given a request containing the refresh token as a  bearer token
        /// - returns:
        ///     The payload contained in the token. See `authenticate<Payload: Codable>(idToken:on:)` for more details
        public func refresh(username: String) async throws -> CognitoAuthenticateResponse {
            guard let bearer = request.headers.bearerAuthorization else {
                throw Abort(.unauthorized)
            }
            return try await self.request.application.cognito.authenticatable.refresh(
                username: username,
                refreshToken: bearer.token,
                context: self.request
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
            let identifiable = self.request.application.cognito.identifiable
            let identity = try await identifiable.getIdentityId(idToken: bearer.token)
            return try await identifiable.getCredentialForIdentity(identityId: identity, idToken: bearer.token)
        }

        let request: Request
    }
}

/// extend Vapor Request to provide Cognito context
extension Request {
    public var contextData: CognitoIdentityProvider.ContextDataType? {
        let host = headers["Host"].first ?? "localhost:8080"
        guard let remoteAddress = remoteAddress else { return nil }
        let ipAddress: String
        switch remoteAddress {
        case .v4(let address):
            ipAddress = address.host
        case .v6(let address):
            ipAddress = address.host
        default:
            return nil
        }

        // guard let ipAddress = req.http.remotePeer.hostname ?? req.http.channel?.remoteAddress?.description else { return nil }
        let httpHeaders = headers.map { CognitoIdentityProvider.HttpHeader(headerName: $0.name, headerValue: $0.value) }
        let contextData = CognitoIdentityProvider.ContextDataType(
            httpHeaders: httpHeaders,
            ipAddress: ipAddress,
            serverName: host,
            serverPath: url.path
        )
        return contextData
    }
}

#if hasFeature(RetroactiveAttribute)
extension Request: @retroactive CognitoContextData {}
#else
extension Request: CognitoContextData {}
#endif
