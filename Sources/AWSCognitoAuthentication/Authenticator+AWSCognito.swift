import AWSCognitoAuthenticationKit
import NIO
import Vapor

extension AWSCognitoAuthenticateResponse: Authenticatable {}
extension AWSCognitoAccessToken: Authenticatable {}

public typealias AWSCognitoBasicAuthenticatable = AWSCognitoAuthenticateResponse
public typealias AWSCognitoAccessAuthenticatable = AWSCognitoAccessToken

/// Authenticator for Cognito username and password
public struct AWSCognitoBasicAuthenticator: BasicAuthenticator {
    
    public init() {}

    public func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<Void> {
        return request.application.awsCognito.authenticatable.authenticate(username: basic.username, password: basic.password, context: request, on:request.eventLoop).map { token in
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
public struct AWSCognitoAccessAuthenticator: BearerAuthenticator {
    
    public init() {}
    
    public func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        return request.application.awsCognito.authenticatable.authenticate(accessToken: bearer.token, on: request.eventLoop).map { token in
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
public struct AWSCognitoIdAuthenticator<Payload: Authenticatable & Codable>: BearerAuthenticator {
    
    public init() {}
    
    public func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        return request.application.awsCognito.authenticatable.authenticate(idToken: bearer.token, on: request.eventLoop).map { (payload: Payload)->() in
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

