import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SolidSignUpTests {
    typealias Problem = SolidSignUp.Problem

    struct Case: Sendable, CustomTestStringConvertible {
        let input: String
        let expected: [Problem]
        var testDescription: String { "\"\(input)\" → \(expected)" }
    }

    private struct Failure: Error {}

    private func form(username: String = "maneet_99", email: String = "maneet@example.com", password: String = "rainy-day-7") -> SolidSignUp.Form {
        SolidSignUp.Form(username: username, email: email, password: password)
    }

    private func problems(_ form: SolidSignUp.Form) -> [Problem] {
        SolidSignUp.Validator().problems(in: form)
    }

    @Test("Usernames: 3 to 20 letters, digits or underscores, after trimming", arguments: [
        Case(input: "ab", expected: [.usernameLength]),
        Case(input: String(repeating: "a", count: 21), expected: [.usernameLength]),
        Case(input: "maneet sri", expected: [.usernameCharacters]),
        Case(input: "é", expected: [.usernameLength, .usernameCharacters]),
        Case(input: "", expected: [.usernameLength]),
    ])
    func usernames(_ example: Case) {
        #expect(problems(form(username: example.input)) == example.expected)
    }

    @Test("Usernames that pass are trimmed first")
    func validUsernames() {
        #expect(problems(form(username: "  ab_9  ")) == [])
        #expect(problems(form(username: String(repeating: "Z", count: 20))) == [])
        #expect(problems(form(username: "  ab  ")) == [.usernameLength])
    }

    @Test("Email addresses need one @, a name and a dotted domain", arguments: [
        "maneet", "@example.com", "maneet@", "maneet@example", "maneet@.com", "maneet@example.", "a@b@example.com", "man eet@example.com",
    ])
    func badEmails(_ email: String) {
        #expect(problems(form(email: email)) == [.emailFormat])
    }

    @Test("Good email addresses pass, surrounding spaces and all")
    func goodEmails() {
        #expect(problems(form(email: "  Maneet@Example.co.uk ")) == [])
        #expect(problems(form(email: "a@b.io")) == [])
        #expect(problems(form(email: "maneet")) == [.emailFormat])
    }

    @Test("Passwords need 8 characters and a digit, and aren't trimmed")
    func passwords() {
        #expect(problems(form(password: "short1")) == [.passwordLength])
        #expect(problems(form(password: "no digits here")) == [.passwordNeedsDigit])
        #expect(problems(form(password: "abc")) == [.passwordLength, .passwordNeedsDigit])
        #expect(problems(form(password: "  1234  ")) == [])
        #expect(problems(form(password: "١٢٣٤٥٦٧٨x")) == [.passwordNeedsDigit])
    }

    @Test("Every problem is reported, in the order Problem declares them")
    func everythingWrong() {
        let broken = form(username: "a!", email: "nope", password: "x")
        #expect(problems(broken) == Problem.allCases)
    }

    @Test("The body uses the backend's keys, a trimmed username and a lower-cased email")
    func body() throws {
        let data = try SolidSignUp.RequestEncoder().body(for: form(username: " maneet_99 ", email: " Maneet@Example.COM ", password: " Pass 1234 "))
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: String])
        #expect(object == ["user_name": "maneet_99", "email": "maneet@example.com", "password": " Pass 1234 "])
    }

    @Test("An invalid form comes back with messages and is never sent")
    func invalidFormIsNotSent() async throws {
        let sent = Recorder<Data>()
        let flow = SolidSignUp.Flow { await sent.record($0) }
        let outcome = try await flow.submit(form(username: "ab", password: "password"))
        #expect(outcome == .invalid(["Usernames are 3 to 20 characters.", "Add at least one number to your password."]))
        let bodies = await sent.values
        #expect(bodies.isEmpty)
    }

    @Test("A valid form is sent once, as the encoder's body")
    func validFormIsSent() async throws {
        let sent = Recorder<Data>()
        let flow = SolidSignUp.Flow { await sent.record($0) }
        let valid = form(email: "Maneet@Example.com")
        let outcome = try await flow.submit(valid)
        #expect(outcome == .submitted)
        let bodies = await sent.values
        let expected = try SolidSignUp.RequestEncoder().body(for: valid)
        #expect(bodies == [expected])
    }

    @Test("A failed send reaches the caller")
    func sendErrors() async {
        let flow = SolidSignUp.Flow { _ in throw Failure() }
        await #expect(throws: Failure.self) {
            try await flow.submit(form())
        }
    }
}
