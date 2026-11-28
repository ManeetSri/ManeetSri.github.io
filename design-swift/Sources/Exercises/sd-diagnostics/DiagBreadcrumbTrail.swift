// Kata: Breadcrumb trail (D24 · Crash reporting design: symbolication and breadcrumbs)
import Foundation

public enum DiagBreadcrumbTrail {
    public enum Level: String, Codable, Equatable, Sendable {
        case info
        case warning
        case error
    }

    public struct Crumb: Codable, Equatable, Sendable {
        public let category: String
        public let message: String
        public let level: Level

        public init(category: String, message: String, level: Level = .info) {
            self.category = category
            self.message = message
            self.level = level
        }

        /// What the crumb costs against the byte budget
        public var cost: Int { category.utf8.count + message.utf8.count }
    }

    /// Where the trail survives between launches: a file or a memory-mapped region in the app, memory in tests
    public protocol Store: Sendable {
        func read() async -> Data?
        func write(_ data: Data) async
        func clear() async
    }

    public struct Limits: Equatable, Sendable {
        /// At most this many crumbs
        public var maxCrumbs: Int
        /// At most this many bytes, adding up every crumb's `cost`
        public var maxBytes: Int
        /// Info crumbs are written to the store after this many crumbs have been added since the last write
        public var persistEvery: Int

        public init(maxCrumbs: Int = 50, maxBytes: Int = 4_096, persistEvery: Int = 10) {
            self.maxCrumbs = maxCrumbs
            self.maxBytes = maxBytes
            self.persistEvery = persistEvery
        }
    }

    public actor Trail {
        public init(store: any Store, limits: Limits = Limits()) {
            // Write your solution here, then run:
            // swift test --filter DiagBreadcrumbTrailTests
        }

        /// The crumbs in memory, oldest first
        public var crumbs: [Crumb] { [] }

        /// Adds a crumb, drops the oldest until the trail is within its limits, and persists it when the rules say so
        public func add(_ crumb: Crumb) async {}

        /// Writes the whole trail to the store now: call it when the app goes to the background
        public func flush() async {}

        /// What the previous launch left in the store, read once: the store is cleared, and nothing or
        /// unreadable data gives an empty trail. Call it at launch, before adding crumbs.
        public func takePreviousLaunch() async -> [Crumb] {
            return []
        }
    }
}
