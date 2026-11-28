// Reference solution: State diagram lint. Reachability is a breadth-first walk from the initial state;
// the other checks are counts over the transitions, grouped by the state they leave.
import Foundation

public enum StateDiagramLint {
    /// One arrow on a state diagram: `from --event [condition]--> to`
    public struct Transition: Hashable, Sendable {
        public let from: String
        public let event: String
        public let to: String
        /// The guard, if any (`guard` is a Swift keyword, hence the name)
        public let condition: String?

        public init(_ from: String, on event: String, to: String, when condition: String? = nil) {
            self.from = from
            self.event = event
            self.to = to
            self.condition = condition
        }
    }

    /// A state machine as a diagram describes it: its states, where it starts, where it may end,
    /// and its transitions in the order they were written
    public struct Diagram: Sendable {
        public let states: [String]
        public let initial: String
        public let finals: [String]
        public let transitions: [Transition]

        public init(states: [String], initial: String, finals: [String] = [], transitions: [Transition]) {
            self.states = states
            self.initial = initial
            self.finals = finals
            self.transitions = transitions
        }
    }

    /// What a reviewer would flag on the diagram
    public enum Problem: Hashable, Sendable {
        /// The initial state, a final state or a transition names a state that isn't declared
        case unknownState(String)
        /// A declared state that no path of transitions reaches from the initial state
        case unreachable(String)
        /// A declared state that isn't final and has no transition to a different state: the machine gets stuck there
        case deadEnd(String)
        /// Several transitions leave `state` on `event`, and their guards don't tell them apart
        case ambiguous(state: String, event: String)
        /// A final state with a transition leaving it
        case leavesFinal(String)
    }

    /// Every problem in the diagram
    public static func problems(in diagram: Diagram) -> Set<Problem> {
        let declared = Set(diagram.states)
        let finals = Set(diagram.finals)
        var problems = Set<Problem>()

        // Names used anywhere must be declared
        let named = [diagram.initial] + diagram.finals + diagram.transitions.flatMap { [$0.from, $0.to] }
        for name in named where !declared.contains(name) {
            problems.insert(.unknownState(name))
        }

        // Breadth-first walk from the initial state
        let exits = Dictionary(grouping: diagram.transitions, by: \.from)
        var reached: Set<String> = [diagram.initial]
        var queue = [diagram.initial]
        while let state = queue.popLast() {
            for transition in exits[state] ?? [] where reached.insert(transition.to).inserted {
                queue.append(transition.to)
            }
        }

        for state in diagram.states {
            let leaving = exits[state] ?? []
            if !reached.contains(state) { problems.insert(.unreachable(state)) }
            if finals.contains(state) {
                if !leaving.isEmpty { problems.insert(.leavesFinal(state)) }
            } else if !leaving.contains(where: { $0.to != state }) {
                problems.insert(.deadEnd(state))
            }
        }

        // Transitions on one event from one state need guards, and different ones
        for (state, leaving) in exits {
            for (event, sameEvent) in Dictionary(grouping: leaving, by: \.event) where sameEvent.count > 1 {
                let conditions = sameEvent.map(\.condition)
                if conditions.contains(nil) || Set(conditions).count < conditions.count {
                    problems.insert(.ambiguous(state: state, event: event))
                }
            }
        }
        return problems
    }

    /// The diagram as Mermaid `stateDiagram-v2` text
    public static func mermaid(_ diagram: Diagram) -> String {
        var lines = ["stateDiagram-v2", "    [*] --> \(diagram.initial)"]
        for transition in diagram.transitions {
            let condition = transition.condition.map { " [\($0)]" } ?? ""
            lines.append("    \(transition.from) --> \(transition.to) : \(transition.event)\(condition)")
        }
        for final in diagram.finals {
            lines.append("    \(final) --> [*]")
        }
        return lines.joined(separator: "\n")
    }
}
