import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct OneTimeCodeSignInTests {
    private typealias SignIn = OneTimeCodeSignIn

    private static let everyEvent: [SignIn.Event] = [
        .submitPhone("+44 7700 900123"), .codeSent, .sendFailed, .submitCode("123456"),
        .codeAccepted, .codeRejected, .changeNumber,
    ]

    /// Applies the events in order, stopping at the first one the machine refuses (nil)
    private func walk(_ events: [SignIn.Event], from start: SignIn.State = .enteringPhone) -> SignIn.State? {
        var state = start
        for event in events {
            guard let next = SignIn.next(state, on: event) else { return nil }
            state = next
        }
        return state
    }

    @Test("Phone, code, accepted: signed in, and nothing moves it after that")
    func happyPath() {
        #expect(SignIn.next(.enteringPhone, on: .submitPhone("+44 7700 900123")) == .sendingCode(phone: "+447700900123"))
        #expect(SignIn.next(.sendingCode(phone: "+447700900123"), on: .codeSent) == .enteringCode(phone: "+447700900123", attemptsLeft: 3))
        #expect(SignIn.next(.enteringCode(phone: "+447700900123", attemptsLeft: 3), on: .submitCode("123456")) == .verifying(phone: "+447700900123", attemptsLeft: 2))

        let signedIn = walk([.submitPhone("+44 7700 900123"), .codeSent, .submitCode("123456"), .codeAccepted])
        #expect(signedIn == .signedIn(phone: "+447700900123"))
        for event in Self.everyEvent {
            #expect(SignIn.next(.signedIn(phone: "+447700900123"), on: event) == nil)
        }
    }

    @Test("A phone number is a + and 8 to 15 ASCII digits; spaces are dropped")
    func phoneValidation() {
        #expect(SignIn.next(.enteringPhone, on: .submitPhone("+1 415 555 0100")) == .sendingCode(phone: "+14155550100"))
        #expect(SignIn.next(.enteringPhone, on: .submitPhone("+4917612345")) == .sendingCode(phone: "+4917612345"))
        for invalid in ["07700 900123", "+44 77", "+44 7700 900123 4567", "+44 77OO 900123", "+٤٤٧٧٠٠٩٠٠١٢٣", "", "+"] {
            #expect(SignIn.next(.enteringPhone, on: .submitPhone(invalid)) == nil, "\(invalid) should be refused")
        }
    }

    @Test("A code is exactly six ASCII digits")
    func codeValidation() {
        let entering = SignIn.State.enteringCode(phone: "+447700900123", attemptsLeft: 3)
        #expect(SignIn.next(entering, on: .submitCode("004213")) == .verifying(phone: "+447700900123", attemptsLeft: 2))
        for invalid in ["12345", "1234567", "12a456", "１２３４５６", "12 456"] {
            #expect(SignIn.next(entering, on: .submitCode(invalid)) == nil, "\(invalid) should be refused")
        }
    }

    @Test("A wrong code goes back to entering one, with an attempt used up")
    func wrongCode() {
        let state = walk([.submitPhone("+447700900123"), .codeSent, .submitCode("111111"), .codeRejected])
        #expect(state == .enteringCode(phone: "+447700900123", attemptsLeft: 2))
        let thenRight = walk([.submitCode("222222"), .codeAccepted], from: state ?? .enteringPhone)
        #expect(thenRight == .signedIn(phone: "+447700900123"))
    }

    @Test("Three wrong codes lock the user out for good")
    func lockOut() {
        let wrong: [SignIn.Event] = [.submitCode("111111"), .codeRejected]
        let locked = walk([.submitPhone("+447700900123"), .codeSent] + wrong + wrong + wrong)
        #expect(locked == .lockedOut)
        for event in Self.everyEvent {
            #expect(SignIn.next(.lockedOut, on: event) == nil)
        }
    }

    @Test("A second submit while verifying is refused, so a double tap sends one code")
    func doubleSubmit() {
        let verifying = SignIn.next(.enteringCode(phone: "+447700900123", attemptsLeft: 3), on: .submitCode("123456"))
        #expect(verifying == .verifying(phone: "+447700900123", attemptsLeft: 2))
        #expect(SignIn.next(.verifying(phone: "+447700900123", attemptsLeft: 2), on: .submitCode("123456")) == nil)
        #expect(SignIn.next(.verifying(phone: "+447700900123", attemptsLeft: 2), on: .changeNumber) == nil)
    }

    @Test("A failed send goes back to phone entry, and the user can change number while entering a code")
    func goingBack() {
        #expect(walk([.submitPhone("+447700900123"), .sendFailed]) == .enteringPhone)
        #expect(walk([.submitPhone("+447700900123"), .codeSent, .changeNumber]) == .enteringPhone)
        #expect(walk([.submitPhone("+447700900123"), .codeSent, .changeNumber, .submitPhone("+14155550100"), .codeSent])
            == .enteringCode(phone: "+14155550100", attemptsLeft: 3))
    }

    @Test("Answers that arrive in the wrong state are refused")
    func lateEvents() {
        let entering = walk([.submitPhone("+447700900123"), .codeSent])
        #expect(entering == .enteringCode(phone: "+447700900123", attemptsLeft: 3))
        #expect(SignIn.next(.enteringCode(phone: "+447700900123", attemptsLeft: 3), on: .codeSent) == nil)
        #expect(SignIn.next(.enteringCode(phone: "+447700900123", attemptsLeft: 3), on: .codeAccepted) == nil)
        #expect(SignIn.next(.enteringPhone, on: .codeAccepted) == nil)
        #expect(SignIn.next(.sendingCode(phone: "+447700900123"), on: .submitPhone("+14155550100")) == nil)
    }
}
