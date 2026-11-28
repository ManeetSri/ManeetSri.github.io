// Kata: An input/output sign-in view model (D27 · Input/output view models; Testing view models)
import Foundation
import Observation

public enum InputOutputSignIn {
    public struct Credentials: Equatable, Sendable {
        public let email: String
        public let password: String

        public init(email: String, password: String) {
            self.email = email
            self.password = password
        }
    }

    public struct Account: Equatable, Sendable {
        public let id: String
        public let name: String

        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }

    /// The failures the sign-in service reports
    public enum SignInError: Error, Equatable, Sendable {
        case wrongCredentials
        case locked(minutes: Int)
        case offline
    }

    public protocol Authenticating: Sendable {
        func signIn(_ credentials: Credentials) async throws -> Account
    }

    /// Everything the screen can tell the view model
    public enum Input: Equatable, Sendable {
        case emailChanged(String)
        case passwordChanged(String)
        /// The email field lost focus
        case emailEditingEnded
        /// The Sign In button, or Return on the keyboard
        case submitTapped
    }

    /// Everything the screen shows that can change
    public struct Output: Equatable, Sendable {
        /// Shown under the email field
        public var emailError: String?
        public var isSubmitEnabled: Bool
        /// Shows a spinner in the button
        public var isSubmitting: Bool
        /// Shown above the button after a failed attempt
        public var failureMessage: String?

        public init(emailError: String? = nil, isSubmitEnabled: Bool = false, isSubmitting: Bool = false, failureMessage: String? = nil) {
            self.emailError = emailError
            self.isSubmitEnabled = isSubmitEnabled
            self.isSubmitting = isSubmitting
            self.failureMessage = failureMessage
        }
    }

    /// Things that happen once, for the coordinator
    public enum Route: Equatable, Sendable {
        case signedIn(Account)
    }

    public static let invalidEmailMessage = "Enter an email address like name@example.com."
    public static let wrongCredentialsMessage = "That email and password don't match."
    public static let offlineMessage = "You're offline. Check your connection and try again."
    public static let genericFailureMessage = "Something went wrong. Try again."

    @MainActor
    @Observable
    public final class ViewModel {
        /// The whole of what the view renders
        public private(set) var output = Output()

        public init(authenticator: any Authenticating, onRoute: @escaping @MainActor (Route) -> Void) {}

        /// The one way in. Returns once the input has been handled; for `.submitTapped`, that's after the
        /// sign-in attempt finishes (or at once, if the tap is ignored).
        public func send(_ input: Input) async {
            // Write your solution here, then run:
            // swift test --filter InputOutputSignInTests
        }
    }
}
