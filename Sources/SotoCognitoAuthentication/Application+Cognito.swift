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
