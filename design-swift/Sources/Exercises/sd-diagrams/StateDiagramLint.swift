// Kata: State diagram lint (D09 · UML state and activity diagrams)
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
        // Write your solution here, then run:
        // swift test --filter StateDiagramLintTests
        return []
    }

    /// The diagram as Mermaid `stateDiagram-v2` text
    public static func mermaid(_ diagram: Diagram) -> String {
        return ""
    }
}
