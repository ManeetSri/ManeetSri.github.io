// Kata: Snapshot planner (D17 · Diffable data sources and snapshots)
import Foundation

public enum UIKitSnapshotPlanner {
    /// One row as the model layer produces it, in display order
    public struct Row: Equatable, Sendable {
        public let id: String
        public let section: String
        public let title: String
        public let detail: String

        public init(id: String, section: String, title: String, detail: String) {
            self.id = id
            self.section = section
            self.title = title
            self.detail = detail
        }
    }

    /// One section of the new snapshot: its identifier and its item identifiers, in order
    public struct Section: Equatable, Sendable {
        public let id: String
        public let items: [String]

        public init(id: String, items: [String]) {
            self.id = id
            self.items = items
        }
    }

    /// What the screen hands to its diffable data source
    public struct Plan: Equatable, Sendable {
        /// The new snapshot's shape: identifiers only, never whole models
        public let sections: [Section]
        /// Items in both the old and the new rows whose content changed: pass these to `reconfigureItems(_:)`
        public let reconfigured: [String]
        /// Item identifiers that appeared more than once in the new rows, each listed once
        public let duplicates: [String]

        public init(sections: [Section], reconfigured: [String], duplicates: [String]) {
            self.sections = sections
            self.reconfigured = reconfigured
            self.duplicates = duplicates
        }
    }

    /// Plans the snapshot for `new`, given the rows the screen showed before (`old`). Sections come in
    /// the order their first row appears; later copies of a repeated item identifier are dropped and
    /// reported; items whose title or detail changed are listed for reconfiguring.
    public static func plan(from old: [Row], to new: [Row]) -> Plan {
        // Write your solution here, then run:
        // swift test --filter UIKitSnapshotPlannerTests
        return Plan(sections: [], reconfigured: [], duplicates: [])
    }
}
