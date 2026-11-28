// Kata: Ownership leak audit (D16 · ARC, ownership graphs and retain cycles across layers)
import Foundation

public enum OwnershipLeakAudit {
    public enum Strength: Sendable, Equatable {
        case strong
        case weak
        case unowned
    }

    /// One stored reference in an ownership graph: `from` holds `to`
    public struct Reference: Sendable, Equatable, CustomStringConvertible {
        public let from: String
        public let to: String
        public let strength: Strength

        public init(_ from: String, _ to: String, _ strength: Strength = .strong) {
            self.from = from
            self.to = to
            self.strength = strength
        }

        public var description: String { "\(from) -\(strength)-> \(to)" }
    }

    public struct Report: Sendable, Equatable {
        /// Objects ARC keeps alive that no root can reach through strong references, in `objects` order
        public var leaked: [String]
        /// Unowned references held by a live object whose target has been freed, in `references` order
        public var dangling: [Reference]

        public init(leaked: [String] = [], dangling: [Reference] = []) {
            self.leaked = leaked
            self.dangling = dangling
        }
    }

    /// Runs ARC over an ownership graph. `roots` are what the app itself still holds (the app delegate,
    /// the window, a navigation stack); everything else lives only while something strong holds it.
    public static func audit(objects: [String], references: [Reference], roots: Set<String>) -> Report {
        // Write your solution here, then run:
        // swift test --filter OwnershipLeakAuditTests
        return Report()
    }

    /// Watches real objects through weak references, so a test can ask which are still alive
    public final class Tracker {
        public init() {}

        /// Starts watching `object` without keeping it alive
        public func track(_ object: AnyObject, as name: String) {
        }

        /// The names of tracked objects that are still alive, in the order they were tracked
        public var survivors: [String] {
            []
        }
    }
}
