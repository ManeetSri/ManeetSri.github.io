// Reference solution: An input/output sign-in view model. The inputs only change a few stored facts
// (the text, whether the email field was touched, whether a request is in flight); the output is computed
// from them, so it can never disagree with itself. The one-off "signed in" goes out through a closure,
// exactly once.
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

    public enum SignInError: Error, Equatable, Sendable {
        case wrongCredentials
        case locked(minutes: Int)
        case offline
    }

    public protocol Authenticating: Sendable {
        func signIn(_ credentials: Credentials) async throws -> Account
    }

    public enum Input: Equatable, Sendable {
        case emailChanged(String)
        case passwordChanged(String)
        case emailEditingEnded
        case submitTapped
    }

    public struct Output: Equatable, Sendable {
        public var emailError: String?
        public var isSubmitEnabled: Bool
        public var isSubmitting: Bool
        public var failureMessage: String?

        public init(emailError: String? = nil, isSubmitEnabled: Bool = false, isSubmitting: Bool = false, failureMessage: String? = nil) {
            self.emailError = emailError
            self.isSubmitEnabled = isSubmitEnabled
            self.isSubmitting = isSubmitting
            self.failureMessage = failureMessage
        }
    }

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
        /// Derived from the stored facts below on every read, so it's always consistent
        public var output: Output {
            Output(
                emailError: emailTouched && !emailIsValid ? InputOutputSignIn.invalidEmailMessage : nil,
                isSubmitEnabled: canSubmit,
                isSubmitting: isSubmitting,
                failureMessage: failureMessage
            )
        }

        private var email = ""
        private var password = ""
        private var emailTouched = false
        private var isSubmitting = false
        private var hasSignedIn = false
        private var failureMessage: String?

        private let authenticator: any Authenticating
        private let onRoute: @MainActor (Route) -> Void

        public init(authenticator: any Authenticating, onRoute: @escaping @MainActor (Route) -> Void) {
            self.authenticator = authenticator
            self.onRoute = onRoute
        }

        public func send(_ input: Input) async {
            switch input {
            case .emailChanged(let text):
                email = text
                failureMessage = nil
            case .passwordChanged(let text):
                password = text
                failureMessage = nil
            case .emailEditingEnded:
                emailTouched = true
            case .submitTapped:
                await submit()
            }
        }

        private var emailIsValid: Bool { InputOutputSignIn.isValidEmail(email) }

        private var canSubmit: Bool { emailIsValid && !password.isEmpty && !isSubmitting && !hasSignedIn }

        private func submit() async {
            guard !isSubmitting, !hasSignedIn else { return }
            emailTouched = true
            guard canSubmit else { return }

            // Trim the email, never the password: spaces can be part of it
            let credentials = Credentials(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            isSubmitting = true
            failureMessage = nil
            do {
                let account = try await authenticator.signIn(credentials)
                isSubmitting = false
                hasSignedIn = true
                onRoute(.signedIn(account))
            } catch {
                isSubmitting = false
                failureMessage = InputOutputSignIn.message(for: error)
            }
        }
    }

    /// One "@", something before it, and after it a dot with at least one character on each side; no spaces
    static func isValidEmail(_ raw: String) -> Bool {
        let email = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.contains(where: \.isWhitespace) else { return false }
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        return parts[1].dropFirst().dropLast().contains(".")
    }

    /// What to tell the user, or nil when the attempt was cancelled rather than failed
    static func message(for error: any Error) -> String? {
        if error is CancellationError { return nil }
        if let error = error as? URLError {
            switch error.code {
            case .cancelled: return nil
            case .notConnectedToInternet, .networkConnectionLost: return offlineMessage
            default: return genericFailureMessage
            }
        }
        guard let error = error as? SignInError else { return genericFailureMessage }
        switch error {
        case .wrongCredentials:
            return wrongCredentialsMessage
        case .locked(let minutes):
            return "Too many attempts. Try again in \(minutes) \(minutes == 1 ? "minute" : "minutes")."
        case .offline:
            return offlineMessage
        }
    }
}
