// Generated from src/dsa/design/content/lessons/sd-unidirectional/sd-udf-tca-reducers.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

/// A reducer is anything that applies an action to state
protocol Reducer<State, Action> {
    associatedtype State
    associatedtype Action
    func reduce(into state: inout State, action: Action)
}

struct Reduce<State, Action>: Reducer {
    let run: (inout State, Action) -> Void
    func reduce(into state: inout State, action: Action) { run(&state, action) }
}

/// What a `body` is: reducers run in order, each seeing the state the one before it left
struct CombineReducers<State, Action>: Reducer {
    let reducers: [any Reducer<State, Action>]
    func reduce(into state: inout State, action: Action) {
        for reducer in reducers { reducer.reduce(into: &state, action: action) }
    }
}

/// A binding action carries which field changed and how to write the new value
struct BindingAction<Root> {
    let keyPath: PartialKeyPath<Root>
    let write: (inout Root) -> Void

    static func set<Value>(_ keyPath: WritableKeyPath<Root, Value>, _ value: Value) -> Self {
        Self(keyPath: keyPath) { $0[keyPath: keyPath] = value }
    }
}

/// Applies binding actions, and ignores every other action
struct BindingReducer<State, Action>: Reducer {
    let extract: (Action) -> BindingAction<State>?
    func reduce(into state: inout State, action: Action) {
        extract(action)?.write(&state)
    }
}

struct Progress: Equatable {
    var currentPage = 0
    var pageCount = 412
    var note = ""
}

enum ProgressAction {
    case binding(BindingAction<Progress>)
    case pageStepperChanged(Int)
    case finishButtonTapped
}

let feature = CombineReducers<Progress, ProgressAction>(reducers: [
    BindingReducer<Progress, ProgressAction> { action in
        if case .binding(let binding) = action { binding } else { nil }
    },
    Reduce<Progress, ProgressAction> { state, action in
        switch action {
        case .binding(let binding) where binding.keyPath == \Progress.note:
            state.note = String(state.note.prefix(12))   // runs after BindingReducer wrote the note
        case .binding:
            break
        case .pageStepperChanged(let page):
            state.currentPage = min(max(page, 0), state.pageCount)
        case .finishButtonTapped:
            state.currentPage = state.pageCount
        }
    },
])

var state = Progress()
let actions: [(String, ProgressAction)] = [
    ("stepper to 30", .pageStepperChanged(30)),
    ("stepper to 999", .pageStepperChanged(999)),
    ("type a long note", .binding(.set(\.note, "The spice must flow"))),
    ("finish", .finishButtonTapped),
]
for (label, action) in actions {
    feature.reduce(into: &state, action: action)
    print("\(label): page \(state.currentPage)/\(state.pageCount), note \"\(state.note)\"")
}
