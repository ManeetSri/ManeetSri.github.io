import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// An authenticator that holds each sign-in until the test answers it, so a test can look at the view
/// model while a request is in flight
private actor GatedAuthenticator: InputOutputSignIn.Authenticating {
    private(set) var received: [InputOutputSignIn.Credentials] = []
    private var waiting: [CheckedContinuation<InputOutputSignIn.Account, any Error>] = []

    func signIn(_ credentials: InputOutputSignIn.Credentials) async throws -> InputOutputSignIn.Account {
        received.append(credentials)
        return try await withCheckedThrowingContinuation { continuation in
            waiting.append(continuation)
        }
    }

    /// Answers the oldest waiting sign-in; does nothing if none is waiting, so a stub that never signs in
    /// fails its expectations instead of hanging
    func succeed(with account: InputOutputSignIn.Account) {
        guard !waiting.isEmpty else { return }
        waiting.removeFirst().resume(returning: account)
    }

    func fail(with error: any Error) {
        guard !waiting.isEmpty else { return }
        waiting.removeFirst().resume(throwing: error)
    }
}

/// Each failure the authenticator can throw, and what the screen should say about it
private let signInFailures: [(any Error, String)] = [
    (InputOutputSignIn.SignInError.wrongCredentials, InputOutputSignIn.wrongCredentialsMessage),
    (InputOutputSignIn.SignInError.locked(minutes: 1), "Too many attempts. Try again in 1 minute."),
    (InputOutputSignIn.SignInError.locked(minutes: 15), "Too many attempts. Try again in 15 minutes."),
    (InputOutputSignIn.SignInError.offline, InputOutputSignIn.offlineMessage),
    (URLError(.notConnectedToInternet), InputOutputSignIn.offlineMessage),
    (URLError(.badServerResponse), InputOutputSignIn.genericFailureMessage),
]

/// The two ways a cancelled request comes back
private let cancellations: [any Error] = [CancellationError(), URLError(.cancelled)]

/// Collects the routes the view model emits
@MainActor
private final class RouteLog {
    var routes: [InputOutputSignIn.Route] = []
}

@Suite(.timeLimit(.minutes(1))) @MainActor struct InputOutputSignInTests {
    typealias SignIn = InputOutputSignIn
    typealias Output = InputOutputSignIn.Output

    static let ada = InputOutputSignIn.Account(id: "u-1", name: "Ada")

    private func makeModel() -> (SignIn.ViewModel, GatedAuthenticator, RouteLog) {
        let authenticator = GatedAuthenticator()
        let log = RouteLog()
        let model = SignIn.ViewModel(authenticator: authenticator) { route in
            log.routes.append(route)
        }
        return (model, authenticator, log)
    }

    /// Types a valid email and password, then taps Sign In and lets the request reach the authenticator
    private func startSubmitting(_ model: SignIn.ViewModel, email: String = "ada@example.com", password: String = "correct horse") async -> Task<Void, Never> {
        await model.send(.emailChanged(email))
        await model.send(.passwordChanged(password))
        let task = Task { await model.send(.submitTapped) }
        await settle()
        return task
    }

    @Test("The email error waits until the field loses focus, then follows the text")
    func emailErrorTiming() async {
        let (model, _, _) = makeModel()

        await model.send(.emailChanged("ada@"))
        #expect(model.output.emailError == nil)

        await model.send(.emailEditingEnded)
        #expect(model.output.emailError == SignIn.invalidEmailMessage)

        await model.send(.emailChanged("ada@example.com"))
        #expect(model.output.emailError == nil)

        await model.send(.emailChanged("ada@example"))
        #expect(model.output.emailError == SignIn.invalidEmailMessage)
    }

    @Test("Only a plausible email address can be submitted", arguments: [
        ("ada@example.com", true),
        ("  ada@example.co.uk\n", true),
        ("a@b.c", true),
        ("ada@example", false),
        ("@example.com", false),
        ("ada@@example.com", false),
        ("ada lovelace@example.com", false),
        ("ada@example.", false),
        ("ada@.com", false),
        ("", false),
    ])
    func emailRule(email: String, isValid: Bool) async {
        let (model, _, _) = makeModel()

        await model.send(.emailChanged(email))
        await model.send(.passwordChanged("hunter2"))
        await model.send(.emailEditingEnded)

        #expect(model.output == Output(emailError: isValid ? nil : SignIn.invalidEmailMessage, isSubmitEnabled: isValid))
    }

    @Test("Sign In needs a password, and any non-empty password counts")
    func passwordRequired() async {
        let (model, _, _) = makeModel()

        await model.send(.emailChanged("ada@example.com"))
        #expect(!model.output.isSubmitEnabled)

        await model.send(.passwordChanged(" "))
        #expect(model.output.isSubmitEnabled)

        await model.send(.passwordChanged(""))
        #expect(!model.output.isSubmitEnabled)
    }

    @Test("Submitting sends the trimmed email and the password as typed, then routes once")
    func successfulSignIn() async {
        let (model, authenticator, log) = makeModel()

        let task = await startSubmitting(model, email: "  ada@example.com ", password: " secret ")
        #expect(model.output == Output(isSubmitEnabled: false, isSubmitting: true))
        #expect(await authenticator.received == [SignIn.Credentials(email: "ada@example.com", password: " secret ")])

        await authenticator.succeed(with: Self.ada)
        await task.value

        #expect(log.routes == [.signedIn(Self.ada)])
        #expect(model.output == Output(isSubmitEnabled: false, isSubmitting: false))

        await model.send(.submitTapped)
        #expect(await authenticator.received.count == 1)
        #expect(log.routes.count == 1)
    }

    @Test("A second tap while signing in sends nothing")
    func noDoubleSubmit() async {
        let (model, authenticator, log) = makeModel()

        let task = await startSubmitting(model)
        await model.send(.submitTapped)
        #expect(await authenticator.received.count == 1)

        await authenticator.succeed(with: Self.ada)
        await task.value
        #expect(await authenticator.received.count == 1)
        #expect(log.routes == [.signedIn(Self.ada)])
    }

    @Test("Each failure gets a message a person can act on", arguments: signInFailures)
    func failureMessages(error: any Error, message: String) async {
        let (model, authenticator, log) = makeModel()

        let task = await startSubmitting(model)
        await authenticator.fail(with: error)
        await task.value

        #expect(model.output == Output(isSubmitEnabled: true, isSubmitting: false, failureMessage: message))
        #expect(log.routes.isEmpty)
    }

    @Test("A cancelled attempt shows no message", arguments: cancellations)
    func cancellationIsSilent(error: any Error) async {
        let (model, authenticator, _) = makeModel()

        let task = await startSubmitting(model)
        #expect(model.output.isSubmitting)
        await authenticator.fail(with: error)
        await task.value

        #expect(model.output == Output(isSubmitEnabled: true))
    }

    @Test("Editing either field clears the last failure")
    func editingClearsFailure() async {
        let (model, authenticator, _) = makeModel()

        let first = await startSubmitting(model)
        await authenticator.fail(with: SignIn.SignInError.wrongCredentials)
        await first.value
        #expect(model.output.failureMessage == SignIn.wrongCredentialsMessage)

        await model.send(.passwordChanged("correct horse battery"))
        #expect(model.output.failureMessage == nil)

        let second = Task { await model.send(.submitTapped) }
        await settle()
        await authenticator.fail(with: SignIn.SignInError.wrongCredentials)
        await second.value
        #expect(model.output.failureMessage == SignIn.wrongCredentialsMessage)

        await model.send(.emailChanged("ada@example.org"))
        #expect(model.output.failureMessage == nil)
    }

    @Test("Submitting a bad email shows its error at once and sends nothing")
    func submitShowsEmailError() async {
        let (model, authenticator, _) = makeModel()

        await model.send(.emailChanged("ada"))
        await model.send(.passwordChanged("hunter2"))
        #expect(model.output.emailError == nil)

        await model.send(.submitTapped)

        #expect(model.output == Output(emailError: SignIn.invalidEmailMessage, isSubmitEnabled: false))
        #expect(await authenticator.received.isEmpty)
    }
}
