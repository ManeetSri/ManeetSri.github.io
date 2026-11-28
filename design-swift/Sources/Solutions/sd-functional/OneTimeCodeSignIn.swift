// Reference solution: One-time code sign-in. One switch over (state, event) lists every allowed transition;
// everything else, including events that arrive too late or twice, falls through to nil.
import Foundation

public enum OneTimeCodeSignIn {
    public enum State: Equatable, Sendable {
        case enteringPhone
        case sendingCode(phone: String)
        case enteringCode(phone: String, attemptsLeft: Int)
        case verifying(phone: String, attemptsLeft: Int)
        case signedIn(phone: String)
        case lockedOut
    }

    public enum Event: Equatable, Sendable {
        case submitPhone(String)
        case codeSent
        case sendFailed
        case submitCode(String)
        case codeAccepted
        case codeRejected
        case changeNumber
    }

    public static let maxAttempts = 3

    public static func next(_ state: State, on event: Event) -> State? {
        switch (state, event) {
        case (.enteringPhone, .submitPhone(let input)):
            guard let phone = normalisedPhone(input) else { return nil }
            return .sendingCode(phone: phone)
        case (.sendingCode(let phone), .codeSent):
            return .enteringCode(phone: phone, attemptsLeft: maxAttempts)
        case (.sendingCode, .sendFailed):
            return .enteringPhone
        case (.enteringCode(let phone, let attemptsLeft), .submitCode(let code)):
            guard isCode(code) else { return nil }
            return .verifying(phone: phone, attemptsLeft: attemptsLeft - 1)
        case (.enteringCode, .changeNumber):
            return .enteringPhone
        case (.verifying(let phone, _), .codeAccepted):
            return .signedIn(phone: phone)
        case (.verifying(let phone, let attemptsLeft), .codeRejected):
            return attemptsLeft > 0 ? .enteringCode(phone: phone, attemptsLeft: attemptsLeft) : .lockedOut
        default:
            return nil
        }
    }

    private static let digits: ClosedRange<Character> = "0"..."9"

    /// "+" and 8 to 15 ASCII digits once spaces are removed, or nil
    private static func normalisedPhone(_ input: String) -> String? {
        let compact = input.filter { $0 != " " }
        guard compact.first == "+" else { return nil }
        let number = compact.dropFirst()
        guard (8...15).contains(number.count), number.allSatisfy(digits.contains) else { return nil }
        return compact
    }

    /// Exactly six ASCII digits. `Character.isNumber` would also accept "٣" and "３".
    private static func isCode(_ code: String) -> Bool {
        code.count == 6 && code.allSatisfy(digits.contains)
    }
}
