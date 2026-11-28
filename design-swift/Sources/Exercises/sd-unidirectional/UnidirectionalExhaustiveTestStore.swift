// Kata: An exhaustive test store (D28 · TCA: exhaustive tests with TestStore)
public enum UnidirectionalExhaustiveTestStore {
    /// Work a reducer asks for, described as a value
    public enum Effect<Action: Sendable>: Sendable {
        /// Nothing to do
        case none
        /// An action the feature sends itself straight away
        case send(Action)
        /// Async work on the main actor that may finish with an action for the feature
        case run(@MainActor @Sendable () async -> Action?)
        /// Each of these, in order
        case merge([Effect])
    }

    /// Something the test didn't assert, or asserted wrongly
    public enum Failure<State: Equatable, Action: Equatable>: Equatable {
        /// After reducing `after`, the state wasn't what the test said it would be
        case stateMismatch(after: Action, expected: State, actual: State)
        /// The test sent `before` while actions it had received weren't asserted yet
        case receivedActionsNotHandled(before: Action, pending: [Action])
        /// The test expected one action, and the feature had sent a different one
        case unexpectedAction(expected: Action, received: Action)
        /// The test expected an action, and none arrived
        case noActionReceived(expected: Action)
        /// The test finished with actions it never received
        case unreceivedActions([Action])
        /// The test finished while effects were still running
        case effectsStillRunning(Int)
    }

    /// Runs a feature in a test and insists that the test accounts for every state change and every action
    @MainActor
    public final class TestStore<State: Equatable, Action: Equatable & Sendable> {
        public private(set) var state: State
        public private(set) var failures: [Failure<State, Action>] = []
        private let reducer: (inout State, Action) -> Effect<Action>

        public init(initialState: State, reducer: @escaping (inout State, Action) -> Effect<Action>) {
            self.state = initialState
            self.reducer = reducer
        }

        /// Effects that have started and not yet finished
        public var runningEffects: Int {
            0
        }

        /// Sends an action from the test. `update` changes a copy of the previous state into the state you
        /// expect; leave it out to say nothing should change.
        public func send(_ action: Action, assert update: ((inout State) -> Void)? = nil) async {
            // Write your solution here, then run:
            // swift test --filter UnidirectionalExhaustiveTestStoreTests
        }

        /// Waits for the next action the feature sent, checks it's `expected`, then reduces it and checks the state
        public func receive(_ expected: Action, assert update: ((inout State) -> Void)? = nil) async {
        }

        /// Ends the test: effects still running are failures (and are cancelled), and so are unreceived actions
        public func finish() async {
        }
    }
}
