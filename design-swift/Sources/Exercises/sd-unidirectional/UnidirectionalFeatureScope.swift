// Kata: Scope child features into a parent (D28 · TCA: composing and scoping features; tree-based and stack-based navigation)
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
            // Write your solution here, then run:
            // swift test --filter UnidirectionalFeatureScopeTests
        }
    }
}

extension UnidirectionalFeatureScope.Reducer {
    /// Runs each reducer in turn on the same state and action; their follow-ups are concatenated in order
    public static func combine(_ reducers: Self...) -> Self {
        Self { _, _ in [] }
    }

    /// A parent reducer that runs `child` on the slice at `state` for the actions `action` matches, and
    /// ignores every other action. The child's follow-ups come back embedded as parent actions.
    public static func scope<ChildState, ChildAction>(
        state path: WritableKeyPath<State, ChildState>,
        action: UnidirectionalFeatureScope.ActionCase<Action, ChildAction>,
        child: UnidirectionalFeatureScope.Reducer<ChildState, ChildAction>
    ) -> Self {
        Self { _, _ in [] }
    }

    /// Runs `child` on the optional state at `state` when it's present, then this reducer. A child action that
    /// arrives while the child state is nil is ignored by the child (this reducer still sees it).
    public func ifLet<ChildState, ChildAction>(
        _ path: WritableKeyPath<State, ChildState?>,
        action: UnidirectionalFeatureScope.ActionCase<Action, ChildAction>,
        child: UnidirectionalFeatureScope.Reducer<ChildState, ChildAction>
    ) -> Self {
        self
    }

    /// Runs `child` on the element whose id the action carries, then this reducer. Actions for an id that
    /// isn't in the collection are ignored by the child. Follow-ups carry the same id.
    public func forEach<Element: Identifiable, ChildAction>(
        _ path: WritableKeyPath<State, [Element]>,
        action: UnidirectionalFeatureScope.ActionCase<Action, (id: Element.ID, action: ChildAction)>,
        child: UnidirectionalFeatureScope.Reducer<Element, ChildAction>
    ) -> Self {
        self
    }
}
