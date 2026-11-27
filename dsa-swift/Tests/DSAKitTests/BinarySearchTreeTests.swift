import Testing
import DSAKit

@Suite struct BinarySearchTreeTests {
    /// A tiny deterministic generator, so the mixed-operation tests do the same thing every run.
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

    /// 50 at the root; 30 and 70 below it; then 20, 40, 60 and 80; then 35, 45, 65 and 75.
    private static let sample = [50, 30, 70, 20, 40, 60, 80, 35, 45, 65, 75]

    @Test("A new tree is empty")
    func startsEmpty() {
        var tree = BinarySearchTree<Int>()
        #expect(tree.isEmpty)
        #expect(tree.count == 0)
        #expect(tree.height == 0)
        #expect(tree.min == nil)
        #expect(tree.max == nil)
        #expect(tree.floor(5) == nil)
        #expect(tree.ceiling(5) == nil)
        #expect(!tree.contains(5))
        #expect(tree.remove(5) == nil)
        #expect(Array(tree) == [])
        #expect(tree.description == "BinarySearchTree([])")
    }

    @Test("A single element is the min, the max and the whole height")
    func single() {
        var tree: BinarySearchTree = [7]
        #expect(tree.count == 1)
        #expect(tree.height == 1)
        #expect(tree.min == 7)
        #expect(tree.max == 7)
        #expect(tree.contains(7))
        #expect(tree.remove(7) == 7)
        #expect(tree.isEmpty)
        #expect(tree.height == 0)
        #expect(tree.insert(8) == true)
        #expect(Array(tree) == [8])
    }

    @Test("insert returns false for a duplicate and changes nothing")
    func duplicates() {
        var tree = BinarySearchTree<Int>()
        #expect(tree.insert(5) == true)
        #expect(tree.insert(3) == true)
        #expect(tree.insert(5) == false)
        #expect(tree.insert(3) == false)
        #expect(tree.count == 2)
        let fromLiteral: BinarySearchTree = [4, 4, 1, 4, 1]
        #expect(Array(fromLiteral) == [1, 4])
        #expect(fromLiteral.count == 2)
    }

    @Test("Elements come out in increasing order, whatever order they went in")
    func sortedIteration() {
        var steps = Steps(seed: 3)
        var values: [Int] = []
        for _ in 0..<500 {
            values.append(steps.next(below: 1_000) - 500)
        }
        let tree = BinarySearchTree(values)
        #expect(Array(tree) == Array(Set(values)).sorted())
        #expect(tree.count == Set(values).count)
        #expect(tree.underestimatedCount == tree.count)
        #expect(tree.map { $0 * 2 }.first == Set(values).min()! * 2)
    }

    @Test("Height depends on the insertion order")
    func height() {
        let balanced: BinarySearchTree = [4, 2, 6, 1, 3, 5, 7]
        #expect(balanced.height == 3)
        let chain: BinarySearchTree = [1, 2, 3, 4, 5, 6, 7]
        #expect(chain.height == 7)
        #expect(balanced == chain)                // same elements, different shapes
        #expect(BinarySearchTree(Self.sample).height == 4)
    }

    @Test("Removing a leaf")
    func removeLeaf() {
        var tree = BinarySearchTree(Self.sample)
        #expect(tree.remove(35) == 35)
        #expect(tree.remove(75) == 75)
        #expect(Array(tree) == [20, 30, 40, 45, 50, 60, 65, 70, 80])
        #expect(tree.height == 4)                 // 45 and 65 still hang at level 4
        #expect(tree.remove(35) == nil)           // already gone
        #expect(tree.count == 9)
    }

    @Test("Removing a node with one child, on either side")
    func removeOneChild() {
        var tree = BinarySearchTree(Self.sample)
        #expect(tree.remove(20) == 20)            // leaf first, so 30 still has two children
        #expect(tree.remove(60) == 60)            // only a right child, 65
        #expect(tree.remove(80) == 80)            // only a left child, 75
        #expect(tree.remove(75) == 75)            // a leaf
        #expect(tree.remove(70) == 70)            // now only a left child, 65
        #expect(Array(tree) == [30, 35, 40, 45, 50, 65])
        #expect(tree.max == 65)
        #expect(tree.height == 4)
        let chain: BinarySearchTree = [1, 2, 3, 4]
        var shorter = chain
        #expect(shorter.remove(1) == 1)           // the root, with only a right child
        #expect(shorter.height == 3)
        #expect(shorter.min == 2)
        #expect(Array(chain) == [1, 2, 3, 4])     // the original is untouched
    }

    @Test("Removing a node with two children uses its successor")
    func removeTwoChildren() {
        var tree = BinarySearchTree(Self.sample)
        #expect(tree.remove(30) == 30)            // successor 35 is deep in the right subtree
        #expect(Array(tree) == [20, 35, 40, 45, 50, 60, 65, 70, 75, 80])
        #expect(tree.remove(50) == 50)            // the root; successor 60 has a right child
        #expect(Array(tree) == [20, 35, 40, 45, 60, 65, 70, 75, 80])
        #expect(tree.height == 4)
        #expect(tree.remove(80) == 80)
        #expect(tree.remove(70) == 70)            // successor 75 is its right child
        #expect(Array(tree) == [20, 35, 40, 45, 60, 65, 75])
        for value in [20, 35, 40, 45, 60, 65, 75] {
            #expect(tree.contains(value))
        }
        #expect(!tree.contains(70) && !tree.contains(50) && !tree.contains(30))
    }

    @Test("Removing every element, root first, leaves an empty tree that still works")
    func removeAllOneByOne() {
        var tree = BinarySearchTree(Self.sample)
        var remaining = Self.sample.sorted()
        for value in Self.sample {
            #expect(tree.remove(value) == value)
            remaining.removeAll { $0 == value }
            #expect(Array(tree) == remaining)
        }
        #expect(tree.isEmpty)
        #expect(tree.insert(1) == true)
        tree.removeAll()
        #expect(tree.isEmpty && tree.count == 0)
    }

    @Test("remove returns the element the tree held, not the argument")
    func removeReturnsStoredElement() {
        struct Tagged: Comparable {
            let key: Int
            let tag: String
            static func < (lhs: Tagged, rhs: Tagged) -> Bool { lhs.key < rhs.key }
            static func == (lhs: Tagged, rhs: Tagged) -> Bool { lhs.key == rhs.key }
        }
        var tree = BinarySearchTree<Tagged>()
        tree.insert(Tagged(key: 1, tag: "stored"))
        #expect(tree.insert(Tagged(key: 1, tag: "second")) == false)
        #expect(tree.remove(Tagged(key: 1, tag: "probe"))?.tag == "stored")
    }

    @Test("floor and ceiling at the edges", arguments: [
        // probe, floor, ceiling, for the elements 20, 30, 40, 50, 60
        (5, nil, 20), (20, 20, 20), (25, 20, 30), (40, 40, 40), (45, 40, 50),
        (59, 50, 60), (60, 60, 60), (61, 60, nil), (Int.max, 60, nil), (Int.min, nil, 20),
    ] as [(Int, Int?, Int?)])
    func floorAndCeiling(probe: Int, floor: Int?, ceiling: Int?) {
        let tree: BinarySearchTree = [40, 20, 60, 30, 50]
        #expect(tree.floor(probe) == floor)
        #expect(tree.ceiling(probe) == ceiling)
    }

    @Test("floor and ceiling on one element")
    func floorCeilingSingle() {
        let tree: BinarySearchTree = [10]
        #expect(tree.floor(9) == nil)
        #expect(tree.floor(10) == 10)
        #expect(tree.floor(11) == 10)
        #expect(tree.ceiling(9) == 10)
        #expect(tree.ceiling(10) == 10)
        #expect(tree.ceiling(11) == nil)
    }

    @Test("Works with any Comparable element, such as String")
    func strings() {
        var words: BinarySearchTree = ["pear", "apple", "fig", "kiwi", "apple"]
        #expect(Array(words) == ["apple", "fig", "kiwi", "pear"])
        #expect(words.floor("grape") == "fig")
        #expect(words.ceiling("grape") == "kiwi")
        #expect(words.ceiling("zebra") == nil)
        #expect(words.remove("fig") == "fig")
        #expect(words.description == #"BinarySearchTree(["apple", "kiwi", "pear"])"#)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        let original: BinarySearchTree = [5, 3, 8, 1, 4]
        var copy = original
        copy.insert(10)
        copy.remove(3)
        #expect(Array(original) == [1, 3, 4, 5, 8])
        #expect(Array(copy) == [1, 4, 5, 8, 10])

        var another = original
        another.removeAll()
        #expect(another.isEmpty)
        #expect(original.count == 5)

        var third = original
        #expect(third.insert(5) == false)        // no change, and still equal
        #expect(third.remove(99) == nil)
        #expect(third == original)
    }

    @Test("Changing a tree inside a for loop over it doesn't disturb the loop")
    func mutateWhileIterating() {
        var tree: BinarySearchTree = [2, 1, 3]
        var seen: [Int] = []
        for value in tree {
            seen.append(value)
            tree.insert(value + 10)
            tree.remove(value)
        }
        #expect(seen == [1, 2, 3])
        #expect(Array(tree) == [11, 12, 13])
    }

    @Test("An iterator keeps working after the tree it came from is gone")
    func iteratorOutlivesTree() {
        var iterator: BinarySearchTree<Int>.Iterator
        do {
            let tree: BinarySearchTree = [2, 1, 3]
            iterator = tree.makeIterator()
        }
        #expect(iterator.next() == 1)
        #expect(iterator.next() == 2)
        #expect(iterator.next() == 3)
        #expect(iterator.next() == nil)
    }

    @Test("A degenerate tree from sorted insertions doesn't overflow the stack")
    func degenerate() {
        // Sorted insertions cost O(n²) in total, so 10,000 is about the most a debug build does
        // quickly. A recursive insert, iteration or deinit overflows a test thread's stack at
        // around 3,000 levels.
        let n = 10_000
        var tree = BinarySearchTree<Int>()
        for value in 0..<n {
            tree.insert(value)
        }
        #expect(tree.count == n)
        #expect(tree.height == n)
        #expect(tree.min == 0)
        #expect(tree.max == n - 1)
        #expect(tree.floor(n + 5) == n - 1)
        #expect(tree.contains(n - 1))
        #expect(tree.elementsEqual(0..<n))

        var copy = tree                           // copying is iterative too
        copy.remove(0)
        #expect(copy.count == n - 1)
        #expect(tree.count == n)

        for value in 0..<(n / 2) {
            tree.remove(value)                    // the root each time: one child
        }
        for value in stride(from: n - 1, to: n - 11, by: -1) {
            #expect(tree.remove(value) == value)  // the deepest leaf
        }
        #expect(tree.height == n / 2 - 10)
        #expect(tree.min == n / 2)
        tree.removeAll()                          // frees 4,990 levels at once
        #expect(tree.isEmpty)

        var descending = BinarySearchTree<Int>()
        for value in stride(from: 4_000, to: 0, by: -1) {
            descending.insert(value)              // a chain of left children
        }
        #expect(descending.height == 4_000)
        #expect(descending.elementsEqual(1...4_000))
    }

    @Test("100,000 elements in random order stay shallow")
    func large() {
        var steps = Steps(seed: 42)
        var values = Array(0..<100_000)
        for i in stride(from: values.count - 1, to: 0, by: -1) {
            values.swapAt(i, steps.next(below: i + 1))
        }
        var tree = BinarySearchTree(values)
        #expect(tree.count == 100_000)
        #expect(tree.height < 60)                 // random orders average about 4.3 ln n − 5, about 45
        #expect(tree.elementsEqual(0..<100_000))
        for value in stride(from: 0, to: 100_000, by: 2) {
            tree.remove(value)
        }
        #expect(tree.count == 50_000)
        #expect(tree.elementsEqual(stride(from: 1, to: 100_000, by: 2)))
    }

    @Test("Thousands of random operations match a Set and a sorted array")
    func matchesModel() {
        var steps = Steps(seed: 2024)
        var tree = BinarySearchTree<Int>()
        var model = Set<Int>()
        var sorted: [Int] = []
        var snapshot = tree
        var snapshotContents: [Int] = []
        var mismatches: [String] = []

        func check(_ condition: Bool, _ message: @autoclosure () -> String) {
            if !condition && mismatches.count < 5 {
                mismatches.append(message())
            }
        }

        for step in 0..<6_000 {
            let value = steps.next(below: 400) - 200
            switch steps.next(below: 10) {
            case 0...3:
                let inserted = model.insert(value).inserted
                if inserted {
                    sorted.insert(value, at: sorted.firstIndex { $0 > value } ?? sorted.count)
                }
                check(tree.insert(value) == inserted, "insert \(value) at step \(step)")
            case 4...6:
                let removed = model.remove(value)
                sorted.removeAll { $0 == value }
                check(tree.remove(value) == removed, "remove \(value) at step \(step)")
            case 7:
                check(tree.contains(value) == model.contains(value), "contains \(value) at step \(step)")
                check(tree.floor(value) == sorted.last { $0 <= value }, "floor \(value) at step \(step)")
                check(tree.ceiling(value) == sorted.first { $0 >= value }, "ceiling \(value) at step \(step)")
            case 8:
                snapshot = tree                   // a copy that must not change from here on
                snapshotContents = sorted
            default:
                check(tree.min == sorted.first && tree.max == sorted.last, "min/max at step \(step)")
                check(tree.count == model.count && tree.isEmpty == model.isEmpty, "count at step \(step)")
            }
            if step % 500 == 0 {
                check(Array(tree) == sorted, "contents at step \(step)")
                check(Array(snapshot) == snapshotContents, "snapshot at step \(step)")
            }
        }
        check(Array(tree) == sorted, "final contents")
        #expect(mismatches == [])
    }
}
