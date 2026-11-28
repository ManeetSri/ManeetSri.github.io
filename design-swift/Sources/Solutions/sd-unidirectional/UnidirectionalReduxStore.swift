// Kata: A Redux-style store with middleware (D28 · From Flux to Redux; Middleware and effects)
//
// Approach: `dispatch` queues the action and, unless an action is already being processed, drains the
// queue one action at a time. Each action runs through the middleware chain recursively: middleware
// number i gets a `next` that continues at i + 1, and the end of the chain is the reducer. Subscribers
// hear about the result before the next queued action starts, so every listener sees every state in order.
public enum UnidirectionalReduxStore {
    /// What a middleware can do besides passing the action on: read the current state, and dispatch new actions
    public struct Context<State, Action> {
        /// The state at the moment you call it
        public let state: () -> State
        /// Sends a new action from the top of the chain. It starts after the current action has finished.
        public let dispatch: (Action) -> Void

        public init(state: @escaping () -> State, dispatch: @escaping (Action) -> Void) {
            self.state = state
            self.dispatch = dispatch
        }
    }

    /// Sees every action before the reducer does. Call `next` at most once to pass an action on (the same
    /// one or another); code after `next` runs once the reducer has. Don't call it to swallow the action.
    public typealias Middleware<State, Action> = (_ context: Context<State, Action>, _ action: Action, _ next: (Action) -> Void) -> Void

    /// One owner for the state: actions go in through `dispatch`, pass every middleware, and reach the reducer
    @MainActor
    public final class Store<State: Equatable, Action> {
        public private(set) var state: State
        private let reducer: (inout State, Action) -> Void
        private let middleware: [Middleware<State, Action>]
        private var listeners: [(id: Int, listener: (State) -> Void)] = []
        private var nextListenerID = 0
        private var queue: [Action] = []
        private var isDispatching = false

        public init(initialState: State, reducer: @escaping (inout State, Action) -> Void, middleware: [Middleware<State, Action>] = []) {
            self.state = initialState
            self.reducer = reducer
            self.middleware = middleware
        }

        /// Sends `action` through the middleware to the reducer, then tells subscribers if the state changed.
        /// An action dispatched while another is being processed waits until that one has finished.
        public func dispatch(_ action: Action) {
            queue.append(action)
            guard !isDispatching else { return }
            isDispatching = true
            defer { isDispatching = false }
            while !queue.isEmpty {
                let next = queue.removeFirst()
                let before = state
                run(next, from: 0)
                if state != before {
                    let current = state
                    for entry in listeners { entry.listener(current) }
                }
            }
        }

        /// Calls `listener` with the current state now, then after every action that changes the state.
        /// Returns an id for `unsubscribe`.
        @discardableResult
        public func subscribe(_ listener: @escaping (State) -> Void) -> Int {
            nextListenerID += 1
            listeners.append((nextListenerID, listener))
            listener(state)
            return nextListenerID
        }

        /// Stops notifying the listener with this id. Unknown ids are ignored.
        public func unsubscribe(_ id: Int) {
            listeners.removeAll { $0.id == id }
        }

        private func run(_ action: Action, from index: Int) {
            guard index < middleware.count else {
                reducer(&state, action)
                return
            }
            let context = Context(state: { self.state }, dispatch: { self.dispatch($0) })
            middleware[index](context, action) { passed in
                self.run(passed, from: index + 1)
            }
        }
    }
}
