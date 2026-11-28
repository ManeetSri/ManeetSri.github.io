// Generated from src/dsa/design/content/lessons/sd-unidirectional/sd-udf-effects.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum Action: Equatable {
    case addTapped(String)
    case signOutTapped
}

struct State {
    var items: [String] = []
    var isSignedIn = true
}

typealias Dispatch = (Action) -> Void
/// Redux's shape: given a way to read the state, and the next link, return this link
typealias Middleware = (_ getState: @escaping () -> State) -> (_ next: @escaping Dispatch) -> Dispatch

let logger: Middleware = { getState in { next in { action in
    print("→ \(action)")
    next(action)
    print("  items: \(getState().items)")
} } }

let analytics: Middleware = { _ in { next in { action in
    if case .addTapped = action { print("  analytics: item added") }
    next(action)
} } }

let signedInOnly: Middleware = { getState in { next in { action in
    if case .addTapped = action, !getState().isSignedIn {
        print("  blocked: signed out")
        return
    }
    next(action)
} } }

final class Store {
    private(set) var state = State()
    private var chain: Dispatch = { _ in }

    init(reducer: @escaping (inout State, Action) -> Void, middleware: [Middleware]) {
        let reduce: Dispatch = { [unowned self] action in reducer(&self.state, action) }
        // The last middleware wraps the reducer; the first one wraps everything
        chain = middleware.reversed().reduce(reduce) { next, link in link({ [unowned self] in self.state })(next) }
    }

    func dispatch(_ action: Action) { chain(action) }
}

let store = Store(reducer: { state, action in
    switch action {
    case .addTapped(let item): state.items.append(item)
    case .signOutTapped: state.isSignedIn = false
    }
}, middleware: [logger, analytics, signedInOnly])

store.dispatch(.addTapped("Milk"))
store.dispatch(.signOutTapped)
store.dispatch(.addTapped("Eggs"))
