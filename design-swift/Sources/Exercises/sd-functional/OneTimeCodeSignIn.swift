// Kata: One-time code sign-in (D07 · Enum state machines)
import Foundation

public enum OneTimeCodeSignIn {
    /// Where the sign-in screen is. Each state carries exactly the data it needs.
    public enum State: Equatable, Sendable {
        case enteringPhone
        case sendingCode(phone: String)
        /// `attemptsLeft` is how many more codes the user may submit
        case enteringCode(phone: String, attemptsLeft: Int)
        case verifying(phone: String, attemptsLeft: Int)
        case signedIn(phone: String)
        case lockedOut
    }

    /// What can happen: the user's input, and the server's answers
    public enum Event: Equatable, Sendable {
        case submitPhone(String)
        case codeSent
        case sendFailed
        case submitCode(String)
        case codeAccepted
        case codeRejected
        case changeNumber
    }

    /// Codes the user may submit for one phone number
    public static let maxAttempts = 3

    /// The state after `event`, or nil when the machine refuses it: the event isn't allowed in this state,
    /// or its input is invalid. A refused event changes nothing.
    public static func next(_ state: State, on event: Event) -> State? {
        // Write your solution here, then run:
        // swift test --filter OneTimeCodeSignInTests
        return nil
    }
}
