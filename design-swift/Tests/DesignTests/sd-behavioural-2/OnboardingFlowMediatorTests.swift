import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@MainActor
private final class RecordingNavigator: OnboardingFlowMediator.Navigator {
    var commands: [OnboardingFlowMediator.Command] = []

    func perform(_ command: OnboardingFlowMediator.Command) {
        commands.append(command)
    }
}

@MainActor
@Suite struct OnboardingFlowMediatorTests {
    typealias Output = OnboardingFlowMediator.Output

    private let navigator = RecordingNavigator()

    /// A started coordinator that has handled `outputs`, and a counter of how often it finished
    private func flow(notificationsAnswered: Bool = false, after outputs: [Output] = []) -> (OnboardingFlowMediator.Coordinator, () -> Int) {
        let coordinator = OnboardingFlowMediator.Coordinator(navigator: navigator, notificationsAlreadyAnswered: notificationsAnswered)
        var finished = 0
        coordinator.onFinish = { finished += 1 }
        coordinator.start()
        outputs.forEach(coordinator.handle)
        return (coordinator, { finished })
    }

    @Test("Starting shows the welcome screen as the root")
    func start() {
        let (coordinator, finished) = flow()
        #expect(navigator.commands == [.setRoot(.welcome)])
        #expect(coordinator.stack == [.welcome])
        #expect(!coordinator.isFinished)
        #expect(finished() == 0)
    }

    @Test("Welcome branches to sign-in or account creation")
    func branches() {
        let (signingIn, _) = flow(after: [.welcomeChoseSignIn])
        #expect(signingIn.stack == [.welcome, .signIn])
        #expect(navigator.commands == [.setRoot(.welcome), .push(.signIn)])

        let other = RecordingNavigator()
        let creating = OnboardingFlowMediator.Coordinator(navigator: other, notificationsAlreadyAnswered: false)
        creating.start()
        creating.handle(.welcomeChoseCreateAccount)
        #expect(creating.stack == [.welcome, .createAccount])
        #expect(other.commands == [.setRoot(.welcome), .push(.createAccount)])
    }

    @Test("A new account goes through the prompt, then profile set-up, then finishes")
    func newAccountFullPath() {
        let (coordinator, finished) = flow(after: [.welcomeChoseCreateAccount, .accountCreated])
        #expect(coordinator.stack == [.notificationsPrompt])

        coordinator.handle(.notificationsAnswered)
        #expect(coordinator.stack == [.notificationsPrompt, .profileSetup])
        #expect(finished() == 0)

        coordinator.handle(.profileSaved)
        #expect(coordinator.isFinished)
        #expect(finished() == 1)
        #expect(navigator.commands == [
            .setRoot(.welcome),
            .push(.createAccount),
            .setRoot(.notificationsPrompt),
            .push(.profileSetup),
        ])
    }

    @Test("Once signed in, the next screen replaces the stack, so Back can't return to sign-in")
    func signingInReplacesTheStack() {
        let (coordinator, _) = flow(after: [.welcomeChoseSignIn, .signedIn(hasProfile: true)])
        #expect(navigator.commands.last == .setRoot(.notificationsPrompt))
        #expect(coordinator.stack == [.notificationsPrompt])

        coordinator.backTapped()
        #expect(coordinator.stack == [.notificationsPrompt])
        #expect(navigator.commands.last == .setRoot(.notificationsPrompt))
    }

    @Test("A returning user with a profile finishes after the prompt, with no profile screen")
    func returningUserSkipsProfile() {
        let (coordinator, finished) = flow(after: [.welcomeChoseSignIn, .signedIn(hasProfile: true), .notificationsAnswered])
        #expect(coordinator.isFinished)
        #expect(finished() == 1)
        #expect(!navigator.commands.contains(.push(.profileSetup)))
    }

    @Test("When notifications were already answered, the prompt is skipped")
    func skipsAnsweredPrompt() {
        let (coordinator, finished) = flow(notificationsAnswered: true, after: [.welcomeChoseCreateAccount, .accountCreated])
        #expect(coordinator.stack == [.profileSetup])
        #expect(navigator.commands == [.setRoot(.welcome), .push(.createAccount), .setRoot(.profileSetup)])

        coordinator.handle(.profileSaved)
        #expect(finished() == 1)
    }

    @Test("Signing in with a profile and the prompt already answered finishes straight away")
    func nothingLeftToAsk() {
        let (coordinator, finished) = flow(notificationsAnswered: true, after: [.welcomeChoseSignIn, .signedIn(hasProfile: true)])
        #expect(coordinator.isFinished)
        #expect(finished() == 1)
        #expect(navigator.commands == [.setRoot(.welcome), .push(.signIn)])
    }

    @Test("Back pops the top screen, but never the root")
    func back() {
        let (coordinator, _) = flow(after: [.welcomeChoseSignIn])
        coordinator.backTapped()
        #expect(coordinator.stack == [.welcome])
        #expect(navigator.commands == [.setRoot(.welcome), .push(.signIn), .pop])

        coordinator.backTapped()
        #expect(coordinator.stack == [.welcome])
        #expect(navigator.commands == [.setRoot(.welcome), .push(.signIn), .pop])
    }

    @Test("After going back, the welcome screen can choose again")
    func chooseAgainAfterBack() {
        let (coordinator, _) = flow(after: [.welcomeChoseSignIn])
        coordinator.backTapped()
        coordinator.handle(.welcomeChoseCreateAccount)
        #expect(coordinator.stack == [.welcome, .createAccount])
    }

    @Test("Outputs from screens that aren't on top are ignored: double taps and stale screens")
    func ignoresStaleOutputs() {
        let (coordinator, finished) = flow(after: [.welcomeChoseCreateAccount, .welcomeChoseCreateAccount])
        #expect(coordinator.stack == [.welcome, .createAccount])

        coordinator.handle(.signedIn(hasProfile: true))
        coordinator.handle(.profileSaved)
        coordinator.handle(.welcomeChoseSignIn)
        #expect(coordinator.stack == [.welcome, .createAccount])
        #expect(navigator.commands == [.setRoot(.welcome), .push(.createAccount)])
        #expect(finished() == 0)
    }

    @Test("Once finished, the coordinator ignores everything and finishes only once")
    func finishedIsFinal() {
        let (coordinator, finished) = flow(notificationsAnswered: true, after: [.welcomeChoseCreateAccount, .accountCreated, .profileSaved])
        let commandsAtFinish = navigator.commands
        #expect(finished() == 1)

        coordinator.handle(.profileSaved)
        coordinator.backTapped()
        coordinator.start()
        #expect(finished() == 1)
        #expect(navigator.commands == commandsAtFinish)
    }
}
