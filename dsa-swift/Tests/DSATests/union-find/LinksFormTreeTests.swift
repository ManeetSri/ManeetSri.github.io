import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LinksFormTreeTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("Trees", arguments: [
        (5, [[0, 1], [0, 2], [0, 3], [1, 4]]),
        (4, [[0, 1], [1, 2], [2, 3]]),
        (2, [[1, 0]]),
        (6, [[5, 4], [4, 3], [2, 4], [1, 2], [0, 2]]),
    ])
    func trees(n: Int, links: [[Int]]) {
        #expect(LinksFormTree.check(n, links) == true)
    }

    @Test("Not trees", arguments: [
        (5, [[0, 1], [1, 2], [2, 3], [1, 3], [1, 4]]),   // a cycle, and too many links
        (4, [[0, 1], [2, 3]]),                           // two pieces
        (4, [[0, 1], [1, 2], [2, 0]]),                   // n - 1 links, but a cycle and a lone node
        (3, [[0, 1], [0, 1]]),                           // the same link twice
        (2, []),                                         // two lone nodes
        (3, [[0, 1]]),
    ])
    func notTrees(n: Int, links: [[Int]]) {
        #expect(LinksFormTree.check(n, links) == false)
    }

    @Test("One node and no links is a tree")
    func single() {
        #expect(LinksFormTree.check(1, []) == true)
    }

    @Test("100,000 nodes: a random tree, then the same tree with one link changed")
    func large() {
        let n = 100_000
        var steps = Steps(seed: 7)
        var links = (1..<n).map { [$0, steps.next(below: $0)] }
        #expect(LinksFormTree.check(n, links) == true)
        // Replace the link that holds node n - 1 with a copy of another link: still n - 1 links,
        // but now a cycle and a lone node
        links[n - 2] = links[0]
        #expect(LinksFormTree.check(n, links) == false)
    }
}
