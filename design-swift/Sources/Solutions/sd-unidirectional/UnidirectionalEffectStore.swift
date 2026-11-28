// Kata: Effects the store runs, cancellable by id (D28 · Middleware and effects; The Elm architecture; TCA: effects and dependencies)
//
// Approach: every running effect gets a token of its own, stored with its optional id and its Task. Cancelling
// by id removes those entries at once and cancels their tasks; a finishing task removes only its own token, so
// an effect that was cancelled and replaced can never remove its replacement. Actions come back through `Send`,
// which drops them once the effect's task has been cancelled.
public enum UnidirectionalEffectStore {
    /// Names a running effect so a later action can cancel it
    public struct EffectID: Hashable, Sendable, ExpressibleByStringLiteral {
        public let name: String

        public init(_ name: String) {
            self.name = name
        }

        public init(stringLiteral name: String) {
            self.name = name
        }
    }

    /// How an effect sends actions back to the store. Once the effect has been cancelled, sending does nothing.
    public struct Send<Action: Sendable>: Sendable {
        private let deliver: @MainActor @Sendable (Action) -> Void

        public init(_ deliver: @escaping @MainActor @Sendable (Action) -> Void) {
            self.deliver = deliver
        }

        @MainActor
        public func callAsFunction(_ action: Action) {
            guard !Task.isCancelled else { return }
            deliver(action)
        }
    }

    /// Work a reducer asks the store to do, described as a value
    public enum Effect<Action: Sendable>: Sendable {
        /// Nothing to do
        case none
        /// Send this action straight away, before `send` returns
        case send(Action)
        /// Start async work that may send actions back. With an `id`, `.cancel(id:)` can stop it; with
        /// `cancelInFlight`, starting it first cancels every running effect with the same id.
        case run(id: EffectID? = nil, cancelInFlight: Bool = false, operation: @Sendable (Send<Action>) async throws -> Void)
        /// Cancel every running effect with this id
        case cancel(id: EffectID)
        /// Perform each of these, in order
        case merge([Effect])
    }

    /// Owns a feature's state, reduces actions one at a time on the main actor, and runs the effects its reducer returns
    @MainActor
    public final class Store<State, Action: Sendable> {
        public private(set) var state: State
        private let reducer: (inout State, Action) -> Effect<Action>
        private var running: [Int: (id: EffectID?, task: Task<Void, Never>)] = [:]
        private var nextToken = 0

        public init(initialState: State, reducer: @escaping (inout State, Action) -> Effect<Action>) {
            self.state = initialState
            self.reducer = reducer
        }

        /// How many `.run` effects have started and not yet finished or been cancelled
        public var runningEffects: Int {
            running.count
        }

        /// Reduces `action` straight away, then performs the effect the reducer returned
        public func send(_ action: Action) {
            let effect = reducer(&state, action)
            perform(effect)
        }

        private func perform(_ effect: Effect<Action>) {
            switch effect {
            case .none:
                break
            case .send(let action):
                send(action)
            case .run(let id, let cancelInFlight, let operation):
                if cancelInFlight, let id { cancel(id) }
                nextToken += 1
                let token = nextToken
                let send = Send<Action> { [weak self] action in self?.send(action) }
                let task = Task { [weak self] in
                    try? await operation(send)
                    self?.finished(token)
                }
                running[token] = (id, task)
            case .cancel(let id):
                cancel(id)
            case .merge(let effects):
                effects.forEach(perform)
            }
        }

        private func cancel(_ id: EffectID) {
            for (token, entry) in running where entry.id == id {
                entry.task.cancel()
                running[token] = nil
            }
        }

        private func finished(_ token: Int) {
            running[token] = nil
        }
    }
}
