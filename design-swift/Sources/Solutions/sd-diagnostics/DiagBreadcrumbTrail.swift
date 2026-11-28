// Reference solution: Breadcrumb trail. An actor owns a small ring of crumbs kept within a count and
// byte budget. Warnings and errors are written through at once, because a crash may follow; info
// crumbs are written in batches to save I/O. The previous launch's trail is read, then cleared.
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
        public var maxCrumbs: Int
        public var maxBytes: Int
        public var persistEvery: Int

        public init(maxCrumbs: Int = 50, maxBytes: Int = 4_096, persistEvery: Int = 10) {
            self.maxCrumbs = maxCrumbs
            self.maxBytes = maxBytes
            self.persistEvery = persistEvery
        }
    }

    public actor Trail {
        private let store: any Store
        private let limits: Limits
        private var buffer: [Crumb] = []
        private var bytes = 0
        private var unsaved = 0

        public init(store: any Store, limits: Limits = Limits()) {
            self.store = store
            self.limits = limits
        }

        public var crumbs: [Crumb] { buffer }

        public func add(_ crumb: Crumb) async {
            let crumb = fitted(crumb)
            buffer.append(crumb)
            bytes += crumb.cost
            // Oldest first, until both budgets hold
            while buffer.count > limits.maxCrumbs || bytes > limits.maxBytes {
                bytes -= buffer.removeFirst().cost
            }
            unsaved += 1
            if crumb.level != .info || unsaved >= limits.persistEvery {
                await flush()
            }
        }

        public func flush() async {
            unsaved = 0
            guard let data = try? JSONEncoder().encode(buffer) else { return }
            await store.write(data)
        }

        public func takePreviousLaunch() async -> [Crumb] {
            let data = await store.read()
            await store.clear()
            guard let data, let crumbs = try? JSONDecoder().decode([Crumb].self, from: data) else { return [] }
            return crumbs
        }

        /// A crumb too big for the whole budget loses characters from the end of its message
        private func fitted(_ crumb: Crumb) -> Crumb {
            guard crumb.cost > limits.maxBytes else { return crumb }
            var message = crumb.message
            while !message.isEmpty && crumb.category.utf8.count + message.utf8.count > limits.maxBytes {
                message.removeLast()
            }
            return Crumb(category: crumb.category, message: message, level: crumb.level)
        }
    }
}
