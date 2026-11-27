// Problem: Copy a network of peers (M42 · Clone a graph)

public enum PeerNetworkClone {
    /// A peer in a network. Links may be one-way or two-way, and a peer may link to itself.
    public final class Peer {
        public var label: Int
        public var links: [Peer]

        public init(_ label: Int, links: [Peer] = []) {
            self.label = label
            self.links = links
        }
    }

    /// Returns a deep copy of every peer reachable from start, with the same labels and the same
    /// links in the same order, made entirely of new Peer objects. Returns the copy of start, or
    /// nil if start is nil.
    public static func clone(_ start: Peer?) -> Peer? {
        // Write your solution here, then run:
        // swift test --filter PeerNetworkCloneTests
        return nil
    }
}
