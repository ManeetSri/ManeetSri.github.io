// Generated from src/dsa/design/content/lessons/sd-unidirectional/sd-udf-flux-redux.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct ShelfState: Equatable {
    var titles: [Int: String] = [:]
    var finished: Set<Int> = []
}

struct ProfileState: Equatable {
    var finishedThisYear = 0
}

struct AppState: Equatable {
    var shelf = ShelfState()
    var profile = ProfileState()
}

/// Events, named after what happened, not after which property to set
enum AppAction {
    case bookAdded(id: Int, title: String)
    case bookFinished(id: Int)
    case bookRemoved(id: Int)
}

/// Each slice reducer sees only its own slice
func shelfReducer(_ state: inout ShelfState, _ action: AppAction) {
    switch action {
    case .bookAdded(let id, let title): state.titles[id] = title
    case .bookFinished(let id): state.finished.insert(id)
    case .bookRemoved(let id):
        state.titles[id] = nil
        state.finished.remove(id)
    }
}

func profileReducer(_ state: inout ProfileState, _ action: AppAction) {
    if case .bookFinished = action { state.finishedThisYear += 1 }
}

/// The root reducer combines the slices, and holds the rules that need more than one of them
func appReducer(_ state: inout AppState, _ action: AppAction) {
    if case .bookFinished(let id) = action, state.shelf.finished.contains(id) || state.shelf.titles[id] == nil {
        return   // already finished, or not on the shelf: the profile mustn't count it
    }
    shelfReducer(&state.shelf, action)
    profileReducer(&state.profile, action)
}

final class Store<State: Equatable, Action> {
    private(set) var state: State
    private(set) var history: [Action] = []
    private let reducer: (inout State, Action) -> Void
    private var subscribers: [(_ old: State, _ new: State) -> Void] = []

    init(_ state: State, reducer: @escaping (inout State, Action) -> Void) {
        self.state = state
        self.reducer = reducer
    }

    func dispatch(_ action: Action) {
        let old = state
        reducer(&state, action)
        history.append(action)
        guard state != old else { return }
        for notify in subscribers { notify(old, state) }
    }

    /// Calls `onChange` only when the selected part of the state changes
    func subscribe<Value: Equatable>(to select: @escaping (State) -> Value, _ onChange: @escaping (Value) -> Void) {
        subscribers.append { old, new in
            let value = select(new)
            if select(old) != value { onChange(value) }
        }
    }
}

let store = Store(AppState(), reducer: appReducer)
store.subscribe(to: { $0.shelf.titles.count }) { print("  → shelf badge shows \($0)") }
store.subscribe(to: { $0.profile.finishedThisYear }) { print("  → profile shows \($0) finished") }

let session: [AppAction] = [
    .bookAdded(id: 1, title: "Dune"),
    .bookAdded(id: 2, title: "Emma"),
    .bookFinished(id: 1),
    .bookFinished(id: 1),
    .bookRemoved(id: 2),
]
for action in session {
    print(action)
    store.dispatch(action)
}

// The state is a fold of the actions, so replaying the log rebuilds it exactly
var replayed = AppState()
for action in store.history { appReducer(&replayed, action) }
print("replay matches:", replayed == store.state)
