// Reference solution: Copy a network of peers. BFS over the original network with a dictionary from
// each original peer to its copy, keyed by ObjectIdentifier (peers are classes, compared by identity,
// and labels may repeat). A copy is made the first time a peer is seen, which is also its visited
// mark, so cycles can't cause an endless loop. When a peer is dequeued, its copy gets links to the
// copies of its links, in the same order. O(peers + links) time and space, and no recursion.

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

    public static func clone(_ start: Peer?) -> Peer? {
        guard let start else { return nil }
        var copies: [ObjectIdentifier: Peer] = [ObjectIdentifier(start): Peer(start.label)]
        var queue = [start]
        var head = 0
        while head < queue.count {
            let original = queue[head]
            head += 1
            let copy = copies[ObjectIdentifier(original)]!
            for link in original.links {
                let id = ObjectIdentifier(link)
                if copies[id] == nil {
                    copies[id] = Peer(link.label)        // copy on first sight: the visited mark
                    queue.append(link)
                }
                copy.links.append(copies[id]!)
            }
        }
        return copies[ObjectIdentifier(start)]
    }
}
