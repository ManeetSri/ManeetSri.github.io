// Reference solution: Ownership leak audit. ARC frees an object when no live object holds it strongly,
// so repeatedly freeing unheld non-roots until nothing changes leaves exactly what ARC keeps. Of those,
// the ones no root reaches through strong references are leaks. O(objects × references) per pass,
// which is plenty for a design-sized graph.
import Foundation

public enum OwnershipLeakAudit {
    public enum Strength: Sendable, Equatable {
        case strong
        case weak
        case unowned
    }

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
        public var leaked: [String]
        public var dangling: [Reference]

        public init(leaked: [String] = [], dangling: [Reference] = []) {
            self.leaked = leaked
            self.dangling = dangling
        }
    }

    public static func audit(objects: [String], references: [Reference], roots: Set<String>) -> Report {
        // Weak and unowned references don't add to the retain count, so only strong ones keep objects alive
        let strong = references.filter { $0.strength == .strong }

        var alive = Set(objects)
        var changed = true
        while changed {
            changed = false
            for object in objects where alive.contains(object) && !roots.contains(object) {
                let held = strong.contains { $0.to == object && alive.contains($0.from) }
                if !held {
                    alive.remove(object)
                    changed = true
                }
            }
        }

        // What the app can still reach: everything else that's alive is a leak
        var reachable = Set<String>()
        var stack = objects.filter { roots.contains($0) }
        while let next = stack.popLast() {
            guard reachable.insert(next).inserted else { continue }
            stack += strong.filter { $0.from == next }.map(\.to)
        }

        let leaked = objects.filter { alive.contains($0) && !reachable.contains($0) }
        let dangling = references.filter { $0.strength == .unowned && alive.contains($0.from) && !alive.contains($0.to) }
        return Report(leaked: leaked, dangling: dangling)
    }

    public final class Tracker {
        private struct Entry {
            let name: String
            weak var object: AnyObject?
        }

        private var entries: [Entry] = []

        public init() {}

        public func track(_ object: AnyObject, as name: String) {
            entries.append(Entry(name: name, object: object))
        }

        public var survivors: [String] {
            entries.filter { $0.object != nil }.map(\.name)
        }
    }
}
