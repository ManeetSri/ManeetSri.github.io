// Problem: Consistent hash ring (M64 · Consistent hashing)

public enum ConsistentHashRing {
    /// A consistent hashing ring. Each server has `virtualNodes` points, at hash("name#0"),
    /// hash("name#1"), …, hash("name#(virtualNodes − 1)"). A key belongs to the point with the smallest
    /// position ≥ hash(key), or, if there's none, the point with the smallest position overall. Points at
    /// the same position are ordered by server name, smallest first.
    public final class Ring {
        /// Points per server. At least 1.
        public let virtualNodes: Int

        public init(virtualNodes: Int, hash: @escaping (String) -> UInt64) {
            self.virtualNodes = virtualNodes
            // Write your solution here, then run:
            // swift test --filter ConsistentHashRingTests
        }

        /// The servers on the ring, sorted by name.
        public var servers: [String] {
            return []
        }

        /// Adds a server's points. Returns false, and changes nothing, if it's already on the ring.
        @discardableResult
        public func addServer(_ name: String) -> Bool {
            return false
        }

        /// Removes a server's points. Returns false if it isn't on the ring.
        @discardableResult
        public func removeServer(_ name: String) -> Bool {
            return false
        }

        /// The server that owns `key`, or nil if the ring is empty.
        public func server(for key: String) -> String? {
            return nil
        }
    }
}
