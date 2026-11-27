import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PeerNetworkCloneTests {
    typealias Peer = PeerNetworkClone.Peer

    /// Peers labelled `labels`, where peer i links to the peers listed in links[i], in that order
    private func network(_ labels: [Int], _ links: [[Int]]) -> [Peer] {
        let peers = labels.map { Peer($0) }
        for (index, targets) in links.enumerated() {
            peers[index].links = targets.map { peers[$0] }
        }
        return peers
    }

    /// Links between peers form reference cycles, so break them when a test is done. Every peer
    /// reachable from `start` is collected first, so freeing a long chain can't set off a deep
    /// cascade of deinits.
    private func release(_ start: Peer?) {
        guard let start else { return }
        var seen: Set<ObjectIdentifier> = [ObjectIdentifier(start)]
        var peers = [start]
        var head = 0
        while head < peers.count {
            let peer = peers[head]
            head += 1
            for link in peer.links where seen.insert(ObjectIdentifier(link)).inserted {
                peers.append(link)
            }
        }
        for peer in peers {
            peer.links = []
        }
    }

    /// Walks the original and the copy side by side, checking that the copy has the same labels and
    /// the same links in the same order, that every copied peer is new, and that it copied exactly
    /// `reachable` peers.
    private func expectFaithfulCopy(of original: Peer, _ copy: Peer?, reachable: Int) {
        guard let copy else {
            Issue.record("clone returned nil for a non-empty network")
            return
        }
        var copyOf: [ObjectIdentifier: Peer] = [ObjectIdentifier(original): copy]
        var originalOf: [ObjectIdentifier: Peer] = [ObjectIdentifier(copy): original]
        var queue = [original]
        var head = 0
        var mistakes: [String] = []
        while head < queue.count && mistakes.isEmpty {
            let peer = queue[head]
            head += 1
            let twin = copyOf[ObjectIdentifier(peer)]!
            if twin === peer {
                mistakes.append("a peer labelled \(peer.label) was reused instead of copied")
            } else if twin.label != peer.label {
                mistakes.append("a copy is labelled \(twin.label) instead of \(peer.label)")
            } else if twin.links.count != peer.links.count {
                mistakes.append("a peer labelled \(peer.label) has \(peer.links.count) links but its copy has \(twin.links.count)")
            }
            for (link, twinLink) in zip(peer.links, twin.links) where mistakes.isEmpty {
                if let known = copyOf[ObjectIdentifier(link)] {
                    if known !== twinLink {
                        mistakes.append("two links to the same peer lead to different copies")
                    }
                } else if originalOf[ObjectIdentifier(twinLink)] != nil {
                    mistakes.append("one copy stands in for two different peers")
                } else {
                    copyOf[ObjectIdentifier(link)] = twinLink
                    originalOf[ObjectIdentifier(twinLink)] = link
                    queue.append(link)
                }
            }
        }
        #expect(mistakes.isEmpty, "\(mistakes.first ?? "")")
        let originals = Set(queue.map { ObjectIdentifier($0) })
        #expect(!originalOf.keys.contains { originals.contains($0) }, "the copy contains original peers")
        if mistakes.isEmpty {
            #expect(copyOf.count == reachable, "expected \(reachable) copied peers")
        }
    }

    @Test("No network")
    func empty() {
        #expect(PeerNetworkClone.clone(nil) == nil)
    }

    @Test("A single peer, alone or linked to itself")
    func single() {
        let alone = Peer(5)
        expectFaithfulCopy(of: alone, PeerNetworkClone.clone(alone), reachable: 1)

        let selfLinked = network([3], [[0]])
        let copy = PeerNetworkClone.clone(selfLinked[0])
        expectFaithfulCopy(of: selfLinked[0], copy, reachable: 1)
        release(selfLinked[0])
        release(copy)
    }

    @Test("A square of two-way links")
    func square() {
        let peers = network([1, 2, 3, 4], [[1, 3], [0, 2], [1, 3], [0, 2]])
        let copy = PeerNetworkClone.clone(peers[0])
        expectFaithfulCopy(of: peers[0], copy, reachable: 4)
        // The original network is untouched
        #expect(peers[0].links[0] === peers[1] && peers[0].links[1] === peers[3])
        #expect(peers[2].links.count == 2)
        release(peers[0])
        release(copy)
    }

    @Test("One-way links: only reachable peers are copied")
    func oneWay() {
        // 0 → 1 → 2 → 0, and 3 → 0, which can't be reached from 0
        let peers = network([10, 20, 30, 40], [[1], [2], [0], [0]])
        let copy = PeerNetworkClone.clone(peers[0])
        expectFaithfulCopy(of: peers[0], copy, reachable: 3)
        release(peers[0])
        release(copy)
    }

    @Test("Peers can share a label")
    func repeatedLabels() {
        let peers = network([7, 7, 7, 7], [[1, 2], [0, 3], [0], [1]])
        let copy = PeerNetworkClone.clone(peers[0])
        expectFaithfulCopy(of: peers[0], copy, reachable: 4)
        release(peers[0])
        release(copy)
    }

    @Test("Repeated links keep their order")
    func repeatedLinks() {
        let peers = network([1, 2, 3], [[1, 1, 0, 2], [2], [1, 0]])
        let copy = PeerNetworkClone.clone(peers[0])
        expectFaithfulCopy(of: peers[0], copy, reachable: 3)
        release(peers[0])
        release(copy)
    }

    @Test("A ring of 100,000 peers")
    func largeRing() {
        // A recursive copy would go 100,000 calls deep, far past a test thread's stack
        let count = 100_000
        let links = (0..<count).map { [($0 + 1) % count, ($0 + count - 1) % count] }
        let peers = network(Array(0..<count), links)
        let copy = PeerNetworkClone.clone(peers[0])
        expectFaithfulCopy(of: peers[0], copy, reachable: count)
        release(peers[0])
        release(copy)
    }

    @Test("A one-way chain of 100,000 peers")
    func largeChain() {
        let count = 100_000
        let links = (0..<count).map { $0 + 1 < count ? [$0 + 1] : [] }
        let peers = network((0..<count).map { $0 % 10 }, links)
        let copy = PeerNetworkClone.clone(peers[0])
        expectFaithfulCopy(of: peers[0], copy, reachable: count)
        release(peers[0])
        release(copy)
    }

    @Test("300 peers all linked to each other")
    func complete() {
        let count = 300
        let links = (0..<count).map { peer in (0..<count).filter { $0 != peer } }
        let peers = network(Array(0..<count), links)
        let copy = PeerNetworkClone.clone(peers[17])
        expectFaithfulCopy(of: peers[17], copy, reachable: count)
        release(peers[17])
        release(copy)
    }
}
