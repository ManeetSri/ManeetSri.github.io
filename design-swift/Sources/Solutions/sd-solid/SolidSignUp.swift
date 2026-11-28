// Reference solution: Split the sign-up form. Each type answers to one group of people: the validator to
// product, the encoder to the backend team, the messages to content design. The flow only decides the
// order things happen in, so it's the one piece that changes when the screen's behaviour does.
import Foundation

public enum SolidSignUp {
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

    public enum Problem: Sendable, Equatable, CaseIterable {
        case usernameLength
        case usernameCharacters
        case emailFormat
        case passwordLength
        case passwordNeedsDigit
    }

    public struct Validator: Sendable {
        public init() {}

        public func problems(in form: Form) -> [Problem] {
            var found: [Problem] = []
            let username = form.username.trimmingCharacters(in: .whitespacesAndNewlines)
            if !(3...20).contains(username.count) { found.append(.usernameLength) }
            if !username.allSatisfy(Self.isUsernameCharacter) { found.append(.usernameCharacters) }
            if !Self.looksLikeEmail(form.email.trimmingCharacters(in: .whitespacesAndNewlines)) { found.append(.emailFormat) }
            if form.password.count < 8 { found.append(.passwordLength) }
            if !form.password.contains(where: Self.isDigit) { found.append(.passwordNeedsDigit) }
            return found
        }

        private static func isDigit(_ character: Character) -> Bool {
            ("0"..."9").contains(character)
        }

        private static func isUsernameCharacter(_ character: Character) -> Bool {
            character == "_" || isDigit(character) || ("a"..."z").contains(character) || ("A"..."Z").contains(character)
        }

        private static func looksLikeEmail(_ email: String) -> Bool {
            guard !email.contains(where: \.isWhitespace) else { return false }
            let parts = email.split(separator: "@", omittingEmptySubsequences: false)
            guard parts.count == 2, !parts[0].isEmpty else { return false }
            let domain = parts[1]
            guard let dot = domain.firstIndex(of: "."), dot != domain.startIndex else { return false }
            return domain.last != "."
        }
    }

    public struct RequestEncoder: Sendable {
        public init() {}

        private struct Body: Encodable {
            let userName: String
            let email: String
            let password: String

            enum CodingKeys: String, CodingKey {
                case userName = "user_name"
                case email
                case password
            }
        }

        public func body(for form: Form) throws -> Data {
            let body = Body(
                userName: form.username.trimmingCharacters(in: .whitespacesAndNewlines),
                email: form.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: form.password
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return try encoder.encode(body)
        }
    }

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

    public struct Flow: Sendable {
        public enum Outcome: Sendable, Equatable {
            case invalid([String])
            case submitted
        }

        private let validator: Validator
        private let encoder: RequestEncoder
        private let messages: Messages
        private let send: @Sendable (Data) async throws -> Void

        public init(validator: Validator = Validator(), encoder: RequestEncoder = RequestEncoder(), messages: Messages = Messages(), send: @escaping @Sendable (Data) async throws -> Void) {
            self.validator = validator
            self.encoder = encoder
            self.messages = messages
            self.send = send
        }

        public func submit(_ form: Form) async throws -> Outcome {
            let problems = validator.problems(in: form)
            guard problems.isEmpty else { return .invalid(problems.map(messages.text(for:))) }
            try await send(try encoder.body(for: form))
            return .submitted
        }
    }
}
