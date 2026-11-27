// Reference solution: thumbnail cache with a byte budget. It's an LRU cache (a dictionary from URL to a
// node, and a doubly linked list of nodes in order of use) with one change: instead of evicting a single
// entry when a count is exceeded, it evicts from the least recently used end *while* the total size is
// over the budget. Every operation is O(1) plus O(1) per image it evicts, and each image is evicted at
// most once, so a sequence of operations is O(1) amortised each.

public enum ThumbnailBudgetCache {
    public final class Cache<Image> {
        final class Node {
            let url: String
            var image: Image
            var bytes: Int
            var newer: Node?              // towards the most recently used end
            weak var older: Node?         // weak, so neighbours don't keep each other alive

            init(url: String, image: Image, bytes: Int) {
                self.url = url
                self.image = image
                self.bytes = bytes
            }
        }

        public let byteBudget: Int
        public private(set) var totalBytes = 0
        private var nodes: [String: Node] = [:]
        private var newest: Node?
        private var oldest: Node?

        public init(byteBudget: Int) {
            precondition(byteBudget > 0, "The budget must be positive")
            self.byteBudget = byteBudget
        }

        public var count: Int { nodes.count }

        // The list runs oldest → newest through `newer`, so the oldest node owns the chain.
        private func unlink(_ node: Node) {
            if let older = node.older { older.newer = node.newer } else { oldest = node.newer }
            if let newer = node.newer { newer.older = node.older } else { newest = node.older }
            node.newer = nil
            node.older = nil
        }

        private func append(_ node: Node) {
            node.older = newest
            newest?.newer = node
            newest = node
            if oldest == nil { oldest = node }
        }

        private func remove(_ node: Node) {
            unlink(node)
            nodes[node.url] = nil
            totalBytes -= node.bytes
        }

        /// Evicts from the oldest end until the total is at most `limit`.
        private func evict(downTo limit: Int) -> [String] {
            var evicted: [String] = []
            while totalBytes > limit, let victim = oldest {
                remove(victim)
                evicted.append(victim.url)
            }
            return evicted
        }

        public func image(for url: String) -> Image? {
            guard let node = nodes[url] else { return nil }
            unlink(node)
            append(node)
            return node.image
        }

        @discardableResult
        public func insert(_ image: Image, for url: String, bytes: Int) -> [String] {
            if let old = nodes[url] { remove(old) }
            guard bytes <= byteBudget else { return [] }   // too big to ever fit: don't cache it
            let node = Node(url: url, image: image, bytes: bytes)
            nodes[url] = node
            append(node)
            totalBytes += bytes
            return evict(downTo: byteBudget)               // never reaches the new node, which fits alone
        }

        @discardableResult
        public func trim(toBytes limit: Int) -> [String] {
            evict(downTo: max(0, limit))
        }

        public var urlsByRecency: [String] {
            var urls: [String] = []
            var node = newest
            while let current = node {
                urls.append(current.url)
                node = current.older
            }
            return urls
        }
    }
}
