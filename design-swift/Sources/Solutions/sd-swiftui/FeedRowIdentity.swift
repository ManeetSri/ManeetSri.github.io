// Reference solution: Stable row ids. Identity comes only from data the item carries, never from
// position or a fresh UUID, and the two id spaces get prefixes so they can't collide. Duplicates
// collapse onto their first position, with the content of their last occurrence.
import Foundation

public enum FeedRowIdentity {
    public struct Item: Equatable, Sendable {
        public var serverID: String?
        public var clientID: String?
        public var title: String
        public var isPending: Bool

        public init(serverID: String? = nil, clientID: String? = nil, title: String, isPending: Bool = false) {
            self.serverID = serverID
            self.clientID = clientID
            self.title = title
            self.isPending = isPending
        }
    }

    public struct Row: Identifiable, Equatable, Sendable {
        public let id: String
        public var title: String
        public var isPending: Bool

        public init(id: String, title: String, isPending: Bool) {
            self.id = id
            self.title = title
            self.isPending = isPending
        }
    }

    public struct Changes: Equatable, Sendable {
        public var inserted: [String]
        public var removed: [String]
        public var updated: [String]

        public init(inserted: [String] = [], removed: [String] = [], updated: [String] = []) {
            self.inserted = inserted
            self.removed = removed
            self.updated = updated
        }
    }

    public static func identity(of item: Item) -> String? {
        if let clientID = item.clientID, !clientID.isEmpty { return "client:" + clientID }
        if let serverID = item.serverID, !serverID.isEmpty { return "server:" + serverID }
        return nil
    }

    public static func rows(from items: [Item]) -> [Row] {
        var rows: [Row] = []
        var position: [String: Int] = [:]
        for item in items {
            guard let id = identity(of: item) else { continue }
            let row = Row(id: id, title: item.title, isPending: item.isPending)
            if let index = position[id] {
                rows[index] = row
            } else {
                position[id] = rows.count
                rows.append(row)
            }
        }
        return rows
    }

    public static func changes(from old: [Row], to new: [Row]) -> Changes {
        let oldByID = Dictionary(old.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let newIDs = Set(new.map(\.id))
        var changes = Changes()
        for row in new {
            if let previous = oldByID[row.id] {
                if previous != row { changes.updated.append(row.id) }
            } else {
                changes.inserted.append(row.id)
            }
        }
        changes.removed = old.map(\.id).filter { !newIDs.contains($0) }
        return changes
    }
}
