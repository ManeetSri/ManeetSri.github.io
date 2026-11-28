// Reference solution: Snapshot planner. One pass over the new rows builds the sections (first appearance
// wins, so a section never appears twice) and drops repeated identifiers, which would crash a diffable
// data source. Reconfigure only what exists on both sides and changed content, in new-snapshot order.
import Foundation

public enum UIKitSnapshotPlanner {
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

    public struct Section: Equatable, Sendable {
        public let id: String
        public let items: [String]

        public init(id: String, items: [String]) {
            self.id = id
            self.items = items
        }
    }

    public struct Plan: Equatable, Sendable {
        public let sections: [Section]
        public let reconfigured: [String]
        public let duplicates: [String]

        public init(sections: [Section], reconfigured: [String], duplicates: [String]) {
            self.sections = sections
            self.reconfigured = reconfigured
            self.duplicates = duplicates
        }
    }

    public static func plan(from old: [Row], to new: [Row]) -> Plan {
        // The old rows the screen actually showed: the first copy of each identifier
        var before: [String: Row] = [:]
        for row in old where before[row.id] == nil {
            before[row.id] = row
        }

        var after: [String: Row] = [:]
        var sectionOrder: [String] = []
        var itemsBySection: [String: [String]] = [:]
        var duplicates: [String] = []
        for row in new {
            guard after[row.id] == nil else {
                if !duplicates.contains(row.id) { duplicates.append(row.id) }
                continue
            }
            after[row.id] = row
            if itemsBySection[row.section] == nil { sectionOrder.append(row.section) }
            itemsBySection[row.section, default: []].append(row.id)
        }

        let sections = sectionOrder.map { Section(id: $0, items: itemsBySection[$0] ?? []) }
        let reconfigured = sections.flatMap(\.items).filter { id in
            guard let old = before[id], let new = after[id] else { return false }
            return old.title != new.title || old.detail != new.detail
        }
        return Plan(sections: sections, reconfigured: reconfigured, duplicates: duplicates)
    }
}
