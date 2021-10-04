# Soto Cognito Authentication
[<img src="http://img.shields.io/badge/swift-5.1-brightgreen.svg" alt="Swift 5.1" />](https://swift.org)
[<img src="https://github.com/adam-fowler/soto-cognito-authentication/workflows/Swift/badge.svg" />](https://github.com/adam-fowler/soto-cognito-authentication/actions?query=workflow%3ASwift)

This is the Vapor wrapper for [Soto Cognito Authentication Kit](https://github.com/adam-fowler/soto-cognito-authentication-kit). It provides application storage for configurations and authentication calls on request. Documentation on Soto Cognito Authentication Kit can be found [here](https://github.com/adam-fowler/soto-cognito-authentication-kit/blob/main/README.md)

# Using with Vapor
## Configuration
Store your `CognitoConfiguration` on the Application object. In configure.swift add the following with your configuration details
```swift
let awsClient = AWSClient(httpClientProvider: .shared(app.http.client.shared))
let awsCognitoConfiguration = CognitoConfiguration(
    userPoolId: String = "eu-west-1_userpoolid",
    clientId: String = "23432clientId234234",
    clientSecret: String = "1q9ln4m892j2cnsdapa0dalh9a3aakmpeugiaag8k3cacijlbkrp",
    cognitoIDP: CognitoIdentityProvider = CognitoIdentityProvider(client: awsClient, region: .euwest1),
    adminClient: true
)
app.cognito.authenticatable = CognitoAuthenticatable(configuration: awsCognitoConfiguration)
```
The CognitoIdentity configuration can be setup in a similar way.
```swift
let awsCognitoIdentityConfiguration = CognitoIdentityConfiguration(
    identityPoolId: String = "eu-west-1_identitypoolid",
    userPoolId: String = "eu-west-1_userpoolid",
    region: .euwest1,
    cognitoIdentity: CognitoIdentity = CognitoIdentity(client: awsClient, region: .euwest1)
)
let app.cognito.identifiable = CognitoIdentifiable(configuration: awsCognitoIdentityConfiguration)
```
## Accessing functionality
Functions like `createUser`, `signUp`, `authenticate` with username and password and `responseToChallenge` are all accessed through `request.application.cognito.authenticatable`. The following login route will return the full response from `CognitoAuthenticable.authenticate`.
```swift
    func login(_ req: Request) throws -> EventLoopFuture<CognitoAuthenticateResponse> {
        let user = try req.content.decode(User.self)
        return req.application.cognito.authenticatable.authenticate(
            username: user.username,
            password: user.password,
            context: req,
            on:req.eventLoop)
    }
```
If id, access or refresh tokens are provided in the 'Authorization' header as Bearer tokens the following functions in Request can be used to verify them `authenticate(idToken:)`, `authenticate(accessToken:)`, `refresh`. as in the following
```swift
func authenticateAccess(_ req: Request) throws -> Future<> {
    req.cognito.authenticateAccess().flatMap { _ in
        ...
    }
}
```

## Authenticators

Three authenticators are available. See the [Vapor docs](https://docs.vapor.codes/4.0/authentication) for more details on authentication in Vapor.`CognitoBasicAuthenticator` will do username, password authentication and returns a `CognitoAuthenticateResponse`. `CognitoAccessAuthenticator` will do access token authentication and returns an `CognitoAccessToken` which holds all the information that could be extracted from the access token. `CognitoIdAuthenticator<Payload>` does id token authentication and extracts information from the id token into your own `Payload` type. The standard list of claims that can be found in an id token are detailed in the [OpenID spec] (https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims). Your `Payload` type needs to decode using these tags, the username tag "cognito:username" and any custom tags you may have setup for the user pool. Below is an example of using the id token authenticator.

First create a User type to store your id token payload in.
```swift
struct User: Content & Authenticatable {
    let username: String
    let email: String

    private enum CodingKeys: String, CodingKey {
        case username = "cognito:username"
        case email = "email"
    }
}
```
Add a route using the authenticator. The `CognitoIdAuthenticator` authenticates the request, the `guardMiddleware` ensures the user is authenticated. The actual function accesses the `User` type via `req.auth.require`.
```swift
app.grouped(CognitoIdAuthenticator<User>())
    .grouped(User.guardMiddleware())
    .get("user") { (req) throws -> EventLoopFuture<User> in
    let user = try req.auth.require(User.self)
    return req.eventLoop.next().makeSucceededFuture(user)
}
```
