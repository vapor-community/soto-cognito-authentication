import AWSCognitoAuthenticationKit
import Vapor

extension AWSCognitoAuthenticateResponse: Authenticatable {}
extension AWSCognitoAccessToken: Authenticatable {}

/// Authenticator for Cognito username and password
public struct AWSCognitoBasicAuthenticator: BasicAuthenticator {
    public typealias User = AWSCognitoAuthenticateResponse
    
    public init() {}
    
    public func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<User?> {
        return request.application.awsCognito.authenticatable.authenticate(username: basic.username, password: basic.password, context: request, on:request.eventLoop).map { $0 }
    }
}

/// Authenticator for Cognito access tokens
public struct AWSCognitoAccessAuthenticator: BearerAuthenticator {
    public typealias User = AWSCognitoAccessToken
    
    public init() {}
    
    public func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<User?> {
        return request.application.awsCognito.authenticatable.authenticate(accessToken: bearer.token, on: request.eventLoop).map { $0 }
    }
}

/// Authenticator for Cognito id tokens. Can use this to extract information from Id Token into Payload struct. The list of standard list of claims found in an id token are
/// detailed in the [OpenID spec] (https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims) . Your `Payload` type needs
/// to decode using these tags, plus the AWS specific "cognito:username" tag and any custom tags you have setup for the user pool.
public struct AWSCognitoIdAuthenticator<Payload: Authenticatable & Codable>: BearerAuthenticator {
    public typealias User = Payload
    
    public init() {}
    
    public func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<User?> {
        return request.application.awsCognito.authenticatable.authenticate(idToken: bearer.token, on: request.eventLoop)
    }
}

