// Reference solution: A mediated onboarding flow. Screens only report outputs; the coordinator owns
// every flow rule: which screen comes next, which steps to skip, when to replace the stack so Back
// can't return to sign-in, and when the flow is over. It drives a Navigator protocol, so tests can
// record what it asked for instead of driving UIKit.
import Foundation

public enum OnboardingFlowMediator {
    public enum Screen: Equatable, Sendable {
        case welcome, signIn, createAccount, notificationsPrompt, profileSetup
    }

    public enum Output: Equatable, Sendable {
        case welcomeChoseSignIn
        case welcomeChoseCreateAccount
        case signedIn(hasProfile: Bool)
        case accountCreated
        case notificationsAnswered
        case profileSaved

        /// The only screen that can send this output
        var source: Screen {
            switch self {
            case .welcomeChoseSignIn, .welcomeChoseCreateAccount: .welcome
            case .signedIn: .signIn
            case .accountCreated: .createAccount
            case .notificationsAnswered: .notificationsPrompt
            case .profileSaved: .profileSetup
            }
        }
    }

    public enum Command: Equatable, Sendable {
        case setRoot(Screen)
        case push(Screen)
        case pop
    }

    @MainActor
    public protocol Navigator: AnyObject {
        func perform(_ command: Command)
    }

    @MainActor
    public final class Coordinator {
        public private(set) var stack: [Screen] = []
        public private(set) var isFinished = false
        public var onFinish: (() -> Void)?

        private let navigator: any Navigator
        private let notificationsAlreadyAnswered: Bool
        private var needsProfile = false

        public init(navigator: any Navigator, notificationsAlreadyAnswered: Bool) {
            self.navigator = navigator
            self.notificationsAlreadyAnswered = notificationsAlreadyAnswered
        }

        public func start() {
            guard stack.isEmpty, !isFinished else { return }
            setRoot(.welcome)
        }

        public func handle(_ output: Output) {
            // A double tap, or a screen that has already gone: only the top screen speaks for the flow
            guard !isFinished, stack.last == output.source else { return }
            switch output {
            case .welcomeChoseSignIn:
                push(.signIn)
            case .welcomeChoseCreateAccount:
                push(.createAccount)
            case .signedIn(let hasProfile):
                needsProfile = !hasProfile
                continueAfterSigningIn()
            case .accountCreated:
                needsProfile = true
                continueAfterSigningIn()
            case .notificationsAnswered:
                if needsProfile { push(.profileSetup) } else { finish() }
            case .profileSaved:
                finish()
            }
        }

        public func backTapped() {
            guard !isFinished, stack.count > 1 else { return }
            stack.removeLast()
            navigator.perform(.pop)
        }

        // Signed in: whatever comes next becomes the root, so Back can't return to the sign-in screens
        private func continueAfterSigningIn() {
            if !notificationsAlreadyAnswered {
                setRoot(.notificationsPrompt)
            } else if needsProfile {
                setRoot(.profileSetup)
            } else {
                finish()
            }
        }

        private func setRoot(_ screen: Screen) {
            stack = [screen]
            navigator.perform(.setRoot(screen))
        }

        private func push(_ screen: Screen) {
            stack.append(screen)
            navigator.perform(.push(screen))
        }

        private func finish() {
            isFinished = true
            onFinish?()
        }
    }
}
