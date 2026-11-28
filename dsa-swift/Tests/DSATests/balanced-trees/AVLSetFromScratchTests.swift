import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AVLSetFromScratchTests {
    typealias AVLSet = AVLSetFromScratch.AVLSet
    typealias Node = AVLSetFromScratch.Node

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    private func makeSet(_ values: [Int]) -> AVLSet {
        let set = AVLSet()
        for value in values {
            set.insert(value)
        }
        return set
    }

    /// The tallest an AVL tree with n nodes can be. The sparsest AVL tree of height h has
    /// N(h) = N(h - 1) + N(h - 2) + 1 nodes, with N(0) = 0 and N(1) = 1.
    private func tallestAllowed(_ n: Int) -> Int {
        var fewest = [0, 1]
        while fewest.last! <= n {
            fewest.append(fewest[fewest.count - 1] + fewest[fewest.count - 2] + 1)
        }
        return fewest.count - 2
    }

    /// Nil if the tree is a valid AVL tree (search order, stored heights, balance factors, count),
    /// or a description of the first problem. Iterative, so even a badly broken tree can't overflow
    /// the stack.
    private func problem(in set: AVLSet) -> String? {
        let sorted = set.sorted
        if sorted.count != set.count { return "count is \(set.count) but the tree has \(sorted.count) nodes" }
        for i in sorted.indices.dropFirst() where sorted[i - 1] >= sorted[i] {
            return "inorder isn't strictly increasing at \(sorted[i - 1]), \(sorted[i])"
        }
        // Preorder puts every parent before its children, so walking it backwards meets children first
        var preorder: [Node] = []
        var stack: [Node] = set.root.map { [$0] } ?? []
        while let node = stack.popLast() {
            preorder.append(node)
            if let left = node.left { stack.append(left) }
            if let right = node.right { stack.append(right) }
        }
        var heights: [ObjectIdentifier: Int] = [:]
        for node in preorder.reversed() {
            let left = node.left.map { heights[ObjectIdentifier($0)]! } ?? 0
            let right = node.right.map { heights[ObjectIdentifier($0)]! } ?? 0
            let height = 1 + max(left, right)
            if node.height != height { return "node \(node.value) stores height \(node.height) but is \(height) tall" }
            if abs(left - right) > 1 { return "node \(node.value) has balance factor \(left - right)" }
            heights[ObjectIdentifier(node)] = height
        }
        return nil
    }

    @Test("A new set is empty")
    func empty() {
        let set = AVLSet()
        #expect(set.count == 0)
        #expect(set.height == 0)
        #expect(!set.contains(1))
        #expect(set.remove(1) == false)
        #expect(set.levelOrder == [])
    }

    @Test("Each insert case ends in the same balanced shape", arguments: [
        [3, 2, 1],     // left-left
        [1, 2, 3],     // right-right
        [3, 1, 2],     // left-right
        [1, 3, 2],     // right-left
    ])
    func fourCases(order: [Int]) {
        let set = makeSet(order)
        #expect(set.levelOrder == [2, 1, 3])
        #expect(set.height == 2)
        #expect(problem(in: set) == nil)
    }

    @Test("Inserting 10, 20, 30, 40, 50, then 25")
    func insertSequence() {
        let set = makeSet([10, 20, 30, 40, 50])
        #expect(set.levelOrder == [20, 10, 40, nil, nil, 30, 50])
        set.insert(25)
        #expect(set.levelOrder == [30, 20, 40, 10, 25, nil, 50])
        #expect(problem(in: set) == nil)
    }

    @Test("Inserting a value that's already there returns false")
    func duplicates() {
        let set = makeSet([5, 3, 8])
        #expect(set.insert(3) == false)
        #expect(set.count == 3)
        #expect(set.insert(4) == true)
        #expect(set.count == 4)
        #expect(set.contains(4))
    }

    @Test("Removing nodes with no, one and two children")
    func removeCases() {
        let set = makeSet([20, 10, 30, 5, 25, 40])
        #expect(set.remove(5) == true)                    // a leaf
        #expect(set.levelOrder == [20, 10, 30, nil, nil, 25, 40])
        #expect(set.remove(10) == true)                   // a leaf, leaving 20 right-heavy by 2
        #expect(set.levelOrder == [30, 20, 40, nil, 25])
        #expect(set.remove(30) == true)                   // two children: 40 moves up, then left-right
        #expect(set.levelOrder == [25, 20, 40])
        #expect(set.remove(30) == false)
        #expect(set.count == 3)
        #expect(problem(in: set) == nil)

        let example = makeSet([20, 10, 30, 25, 40])          // the statement's last example
        #expect(example.remove(30) == true)
        #expect(example.levelOrder == [20, 10, 40, nil, nil, 25])
    }

    @Test("Removal rotations: single, double, and at two levels")
    func removeRotations() {
        let level = makeSet([2, 1, 4, 3, 5])
        level.remove(1)                                   // 4 has balance 0: one left rotation
        #expect(level.levelOrder == [4, 2, 5, nil, 3])

        let bent = makeSet([5, 2, 8, 1, 4, 9, 3])
        bent.remove(9)                                    // 2 leans right: left-right
        #expect(bent.levelOrder == [4, 2, 5, 1, 3, nil, 8])

        let fibonacci = makeSet([8, 5, 11, 3, 7, 10, 12, 2, 4, 6, 9, 1])
        #expect(fibonacci.height == 5)
        fibonacci.remove(12)                              // rotates at 11, then again at 8
        #expect(fibonacci.levelOrder == [5, 3, 8, 2, 4, 7, 10, 1, nil, nil, nil, 6, nil, 9, 11])
        #expect(problem(in: fibonacci) == nil)
    }

    @Test("Random inserts and removes match a Set, with every invariant holding")
    func randomOperations() {
        var steps = Steps(seed: 1_962)
        let set = AVLSet()
        var model = Set<Int>()
        var mismatches = 0
        var firstProblem: String?
        for round in 1...10_000 {
            let value = steps.next(below: 800) - 400
            if steps.next(below: 3) < 2 {
                if set.insert(value) != model.insert(value).inserted { mismatches += 1 }
            } else {
                if set.remove(value) != (model.remove(value) != nil) { mismatches += 1 }
            }
            if set.contains(value) != model.contains(value) { mismatches += 1 }
            if round % 500 == 0 {
                firstProblem = firstProblem ?? problem(in: set)
                if set.sorted != model.sorted() { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
        #expect(firstProblem == nil)
    }

    @Test("100,000 sorted inserts keep the tree short")
    func sortedInserts() {
        let n = 100_000
        let set = AVLSet()
        for value in 0..<n {
            set.insert(value)
        }
        #expect(set.count == n)
        #expect(set.height <= tallestAllowed(n))
        #expect(problem(in: set) == nil)
    }

    @Test("50,000 descending inserts, then removing every other value")
    func descendingThenRemove() {
        let n = 50_000
        let set = AVLSet()
        for value in stride(from: n, to: 0, by: -1) {
            set.insert(value)
        }
        for value in stride(from: 2, through: n, by: 2) {
            set.remove(value)
        }
        #expect(set.count == n / 2)
        #expect(set.height <= tallestAllowed(n / 2))
        #expect(set.contains(1) && !set.contains(2) && set.contains(n - 1))
        #expect(problem(in: set) == nil)
    }
}
