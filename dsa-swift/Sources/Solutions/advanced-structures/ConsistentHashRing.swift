// Reference solution: a consistent hashing ring. Every server has `virtualNodes` points, at
// hash("name#0"), hash("name#1"), …, kept in one array sorted by (position, name). A key belongs to the
// first point at or after hash(key), wrapping round to the first point: a lower-bound binary search,
// O(log p) for p points. Sorting by name as well as position settles ties, since the first point at a
// shared position then belongs to the smallest name. Points store a small server number rather than
// the name, and the array is re-sorted lazily, at the first lookup after servers were added, so adding
// many servers in a row costs one O(p log p) sort. Removing a server filters its points out, O(p).

public enum ConsistentHashRing {
    public final class Ring {
        public let virtualNodes: Int
        private let hash: (String) -> UInt64
        private var names: [String] = []                  // server number → name
        private var numbers: [String: Int] = [:]          // name → server number, for servers on the ring
        private var points: [(position: UInt64, server: Int)] = []
        private var needsSort = false

        public init(virtualNodes: Int, hash: @escaping (String) -> UInt64) {
            self.virtualNodes = max(1, virtualNodes)
            self.hash = hash
        }

        public var servers: [String] {
            numbers.keys.sorted()
        }

        @discardableResult
        public func addServer(_ name: String) -> Bool {
            guard numbers[name] == nil else { return false }
            let number = names.count
            names.append(name)
            numbers[name] = number
            for i in 0..<virtualNodes {
                points.append((hash("\(name)#\(i)"), number))
            }
            needsSort = true
            return true
        }

        @discardableResult
        public func removeServer(_ name: String) -> Bool {
            guard let number = numbers.removeValue(forKey: name) else { return false }
            points.removeAll { $0.server == number }      // keeps the rest in order
            return true
        }

        public func server(for key: String) -> String? {
            guard !points.isEmpty else { return nil }
            if needsSort {
                points.sort { $0.position != $1.position ? $0.position < $1.position : names[$0.server] < names[$1.server] }
                needsSort = false
            }
            let position = hash(key)
            var low = 0
            var high = points.count
            while low < high {
                let mid = (low + high) / 2
                if points[mid].position < position { low = mid + 1 } else { high = mid }
            }
            return names[points[low == points.count ? 0 : low].server]
        }
    }
}
