// Kata: An exhaustive test store (D28 · TCA: exhaustive tests with TestStore)
//
// Approach: the store keeps the real state, a queue of actions that effects have sent but the test hasn't
// received yet, and the tasks of effects still running. Every step works out the expected state by applying
// the test's closure to a copy of the state before the step, reduces for real, and records a failure when the
// two differ. Received actions wait in the queue until the test receives them, so nothing the feature does
// can go unasserted: leftovers are failures when the test sends again or finishes.
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
        private var received: [Action] = []
        private var running: [Int: Task<Void, Never>] = [:]
        private var nextToken = 0

        public init(initialState: State, reducer: @escaping (inout State, Action) -> Effect<Action>) {
            self.state = initialState
            self.reducer = reducer
        }

        /// Effects that have started and not yet finished
        public var runningEffects: Int {
            running.count
        }

        /// Sends an action from the test. `update` changes a copy of the previous state into the state you
        /// expect; leave it out to say nothing should change.
        public func send(_ action: Action, assert update: ((inout State) -> Void)? = nil) async {
            if !received.isEmpty {
                failures.append(.receivedActionsNotHandled(before: action, pending: received))
                received.removeAll()
            }
            apply(action, update)
        }

        /// Waits for the next action the feature sent, checks it's `expected`, then reduces it and checks the state
        public func receive(_ expected: Action, assert update: ((inout State) -> Void)? = nil) async {
            await waitUntil { !self.received.isEmpty || self.running.isEmpty }
            guard !received.isEmpty else {
                failures.append(.noActionReceived(expected: expected))
                return
            }
            let action = received.removeFirst()
            guard action == expected else {
                failures.append(.unexpectedAction(expected: expected, received: action))
                return
            }
            apply(action, update)
        }

        /// Ends the test: effects still running are failures (and are cancelled), and so are unreceived actions
        public func finish() async {
            await waitUntil { self.running.isEmpty }
            if !running.isEmpty {
                failures.append(.effectsStillRunning(running.count))
                running.values.forEach { $0.cancel() }
                running.removeAll()
            }
            if !received.isEmpty {
                failures.append(.unreceivedActions(received))
                received.removeAll()
            }
        }

        private func apply(_ action: Action, _ update: ((inout State) -> Void)?) {
            var expected = state
            update?(&expected)
            let effect = reducer(&state, action)
            if state != expected {
                failures.append(.stateMismatch(after: action, expected: expected, actual: state))
            }
            perform(effect)
        }

        private func perform(_ effect: Effect<Action>) {
            switch effect {
            case .none:
                break
            case .send(let action):
                received.append(action)
            case .run(let operation):
                nextToken += 1
                let token = nextToken
                running[token] = Task { [weak self] in
                    let action = await operation()
                    guard let self, !Task.isCancelled else { return }
                    if let action { self.received.append(action) }
                    self.running[token] = nil
                }
            case .merge(let effects):
                effects.forEach(perform)
            }
        }

        /// Lets effects run until `condition` holds, a bounded number of times so a test can't hang
        private func waitUntil(_ condition: () -> Bool) async {
            for _ in 0..<1_000 where !condition() {
                await Task.yield()
            }
        }
    }
}
