// Kata: Stable row ids (D18 · Views as values: structural and explicit identity; Performance)
import Foundation

public enum FeedRowIdentity {
    /// An item as the feed has it: synced from the server (`serverID`), a draft made on this device
    /// (`clientID`), or both once the server has confirmed a draft and echoed its client id back
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

    /// What a `ForEach` row is built from
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

    /// What a list would animate between two sets of rows
    public struct Changes: Equatable, Sendable {
        /// Ids only in the new rows, in the new rows' order
        public var inserted: [String]
        /// Ids only in the old rows, in the old rows' order
        public var removed: [String]
        /// Ids in both whose title or pending flag changed, in the new rows' order
        public var updated: [String]

        public init(inserted: [String] = [], removed: [String] = [], updated: [String] = []) {
            self.inserted = inserted
            self.removed = removed
            self.updated = updated
        }
    }

    /// `"client:<clientID>"` when the item has a non-empty client id, otherwise `"server:<serverID>"`
    /// when it has a non-empty server id, otherwise nil: the item can't be identified
    public static func identity(of item: Item) -> String? {
        // Write your solution here, then run:
        // swift test --filter FeedRowIdentityTests
        nil
    }

    /// One row per identity, in the order identities first appear. A repeated identity keeps its first
    /// position and takes the title and pending flag of its last occurrence. Items with no identity are left out.
    public static func rows(from items: [Item]) -> [Row] {
        []
    }

    /// The insertions, removals and updates from `old` to `new`. Rows that only moved aren't reported.
    public static func changes(from old: [Row], to new: [Row]) -> Changes {
        Changes()
    }
}
