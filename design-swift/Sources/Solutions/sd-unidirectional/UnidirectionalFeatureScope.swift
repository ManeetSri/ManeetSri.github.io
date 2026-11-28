// Kata: Scope child features into a parent (D28 · TCA: composing and scoping features; tree-based and stack-based navigation)
//
// Approach: every operator returns a new parent reducer. `scope` extracts the child action, runs the child
// on its slice through the key path and embeds the child's follow-up actions back into parent actions.
// `ifLet` and `forEach` do the same for an optional child and for a collection addressed by id, and run the
// child *before* the parent, so a parent that removes a child in response to one of its actions can't starve
// the child of that action. The runtime sends follow-ups first in, first out.
public enum UnidirectionalFeatureScope {
    /// Applies one action to the state and returns the actions to send next, in order: the way a child
    /// tells its parent something happened, and the way one action leads to another
    public struct Reducer<State, Action> {
        public let reduce: (inout State, Action) -> [Action]

        public init(_ reduce: @escaping (inout State, Action) -> [Action]) {
            self.reduce = reduce
        }
    }

    /// How a parent action wraps a child action, like an enum case with an associated value: `extract` takes
    /// the child action out (nil when the parent action is something else), `embed` wraps one up
    public struct ActionCase<Parent, Child> {
        public let extract: (Parent) -> Child?
        public let embed: (Child) -> Parent

        public init(extract: @escaping (Parent) -> Child?, embed: @escaping (Child) -> Parent) {
            self.extract = extract
            self.embed = embed
        }
    }

    /// Holds a feature's state and sends actions through its reducer, one at a time
    public struct Runtime<State, Action> {
        public private(set) var state: State
        /// Every action the reducer has handled, in order, follow-ups included
        public private(set) var log: [Action] = []
        private let reducer: Reducer<State, Action>

        public init(state: State, reducer: Reducer<State, Action>) {
            self.state = state
            self.reducer = reducer
        }

        /// Reduces `action`, then every follow-up action, first in first out, until there are none left
        public mutating func send(_ action: Action) {
            var queue = [action]
            while !queue.isEmpty {
                let next = queue.removeFirst()
                log.append(next)
                queue += reducer.reduce(&state, next)
            }
        }
    }
}

extension UnidirectionalFeatureScope.Reducer {
    /// Runs each reducer in turn on the same state and action; their follow-ups are concatenated in order
    public static func combine(_ reducers: Self...) -> Self {
        Self { state, action in
            reducers.flatMap { $0.reduce(&state, action) }
        }
    }

    /// A parent reducer that runs `child` on the slice at `state` for the actions `action` matches, and
    /// ignores every other action. The child's follow-ups come back embedded as parent actions.
    public static func scope<ChildState, ChildAction>(
        state path: WritableKeyPath<State, ChildState>,
        action: UnidirectionalFeatureScope.ActionCase<Action, ChildAction>,
        child: UnidirectionalFeatureScope.Reducer<ChildState, ChildAction>
    ) -> Self {
        Self { state, parentAction in
            guard let childAction = action.extract(parentAction) else { return [] }
            return child.reduce(&state[keyPath: path], childAction).map(action.embed)
        }
    }

    /// Runs `child` on the optional state at `state` when it's present, then this reducer. A child action that
    /// arrives while the child state is nil is ignored by the child (this reducer still sees it).
    public func ifLet<ChildState, ChildAction>(
        _ path: WritableKeyPath<State, ChildState?>,
        action: UnidirectionalFeatureScope.ActionCase<Action, ChildAction>,
        child: UnidirectionalFeatureScope.Reducer<ChildState, ChildAction>
    ) -> Self {
        Self { state, parentAction in
            var followUps: [Action] = []
            if let childAction = action.extract(parentAction), var childState = state[keyPath: path] {
                followUps = child.reduce(&childState, childAction).map(action.embed)
                state[keyPath: path] = childState
            }
            return followUps + reduce(&state, parentAction)
        }
    }

    /// Runs `child` on the element whose id the action carries, then this reducer. Actions for an id that
    /// isn't in the collection are ignored by the child. Follow-ups carry the same id.
    public func forEach<Element: Identifiable, ChildAction>(
        _ path: WritableKeyPath<State, [Element]>,
        action: UnidirectionalFeatureScope.ActionCase<Action, (id: Element.ID, action: ChildAction)>,
        child: UnidirectionalFeatureScope.Reducer<Element, ChildAction>
    ) -> Self {
        Self { state, parentAction in
            var followUps: [Action] = []
            if let (id, childAction) = action.extract(parentAction),
               let index = state[keyPath: path].firstIndex(where: { $0.id == id }) {
                followUps = child.reduce(&state[keyPath: path][index], childAction).map { action.embed((id, $0)) }
            }
            return followUps + reduce(&state, parentAction)
        }
    }
}
