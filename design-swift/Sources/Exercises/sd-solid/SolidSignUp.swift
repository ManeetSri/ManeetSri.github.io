// Kata: Split the sign-up form (D04 · Single responsibility: reasons to change)
import DesignKit
import Foundation

public enum SolidSignUp {
    /// What the person typed, exactly as they typed it
    public struct Form: Sendable, Equatable {
        public var username: String
        public var email: String
        public var password: String

        public init(username: String, email: String, password: String) {
            self.username = username
            self.email = email
            self.password = password
        }
    }

    /// Every way a form can be wrong, in the order problems are reported
    public enum Problem: Sendable, Equatable, CaseIterable {
        case usernameLength
        case usernameCharacters
        case emailFormat
        case passwordLength
        case passwordNeedsDigit
    }

    /// The product team's rules for a valid account. Changes when those rules change, and only then.
    public struct Validator: Sendable {
        public init() {}

        /// Every problem with the form, in the order `Problem` declares them; empty when it's valid
        public func problems(in form: Form) -> [Problem] {
            // Write your solution here, then run:
            // swift test --filter SolidSignUpTests
            return []
        }
    }

    /// The backend's contract for the sign-up request body. Changes when the endpoint does.
    public struct RequestEncoder: Sendable {
        public init() {}

        /// A JSON object with exactly the keys `user_name`, `email` and `password`
        public func body(for form: Form) throws -> Data {
            throw Unimplemented()
        }
    }

    /// Content design's copy. Already written: it changes when the wording does, and nothing else
    /// has to change with it.
    public struct Messages: Sendable {
        public init() {}

        public func text(for problem: Problem) -> String {
            switch problem {
            case .usernameLength: "Usernames are 3 to 20 characters."
            case .usernameCharacters: "Use only letters, numbers and underscores."
            case .emailFormat: "That email address doesn't look right."
            case .passwordLength: "Passwords need at least 8 characters."
            case .passwordNeedsDigit: "Add at least one number to your password."
            }
        }
    }

    /// What the screen calls. It decides the order of the steps and owns none of the rules.
    public struct Flow: Sendable {
        public enum Outcome: Sendable, Equatable {
            /// The form wasn't sent; these messages explain why, in order
            case invalid([String])
            /// The body was sent and the send didn't throw
            case submitted
        }

        private let validator: Validator
        private let encoder: RequestEncoder
        private let messages: Messages
        private let send: @Sendable (Data) async throws -> Void

        /// `send` posts a request body to the sign-up endpoint. Production passes the API client's
        /// method; tests pass a closure that records what it was given.
        public init(validator: Validator = Validator(), encoder: RequestEncoder = RequestEncoder(), messages: Messages = Messages(), send: @escaping @Sendable (Data) async throws -> Void) {
            self.validator = validator
            self.encoder = encoder
            self.messages = messages
            self.send = send
        }

        /// Validates the form; sends it only when it's valid. Errors from `send` reach the caller.
        public func submit(_ form: Form) async throws -> Outcome {
            throw Unimplemented()
        }
    }
}
