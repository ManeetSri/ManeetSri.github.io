// Kata: A mediated onboarding flow (D13 · Mediator: coordinators as mediators)
import Foundation

public enum OnboardingFlowMediator {
    /// The screens in the flow. None of them knows about the others.
    public enum Screen: Equatable, Sendable {
        case welcome, signIn, createAccount, notificationsPrompt, profileSetup
    }

    /// What screens report to the coordinator. Each output comes from exactly one screen:
    /// the two `welcome…` outputs from `.welcome`, `signedIn` from `.signIn`, `accountCreated` from
    /// `.createAccount`, `notificationsAnswered` from `.notificationsPrompt`, `profileSaved` from `.profileSetup`.
    public enum Output: Equatable, Sendable {
        case welcomeChoseSignIn
        case welcomeChoseCreateAccount
        case signedIn(hasProfile: Bool)
        case accountCreated
        case notificationsAnswered
        case profileSaved
    }

    /// What the coordinator asks the navigation layer to do
    public enum Command: Equatable, Sendable {
        /// Replace the whole stack with one screen (no way back)
        case setRoot(Screen)
        case push(Screen)
        case pop
    }

    /// The navigation layer: a UINavigationController in the app, a recorder in tests
    @MainActor
    public protocol Navigator: AnyObject {
        func perform(_ command: Command)
    }

    @MainActor
    public final class Coordinator {
        /// The screens on the navigation stack, bottom first, as the coordinator last arranged them
        public private(set) var stack: [Screen] = []
        /// True once the flow has ended; after that the coordinator ignores everything
        public private(set) var isFinished = false
        /// Called exactly once, when the flow ends
        public var onFinish: (() -> Void)?

        private let navigator: any Navigator
        private let notificationsAlreadyAnswered: Bool

        public init(navigator: any Navigator, notificationsAlreadyAnswered: Bool) {
            self.navigator = navigator
            self.notificationsAlreadyAnswered = notificationsAlreadyAnswered
        }

        /// Shows the welcome screen as the root of the flow
        public func start() {
            // Write your solution here, then run:
            // swift test --filter OnboardingFlowMediatorTests
        }

        /// A screen reported something. Outputs from a screen that isn't on top of the stack are ignored.
        public func handle(_ output: Output) {
        }

        /// The user tapped Back on the top screen
        public func backTapped() {
        }
    }
}
