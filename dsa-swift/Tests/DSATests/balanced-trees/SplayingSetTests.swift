import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias SplaySet = SplayingSet.SplaySet

/// The key of the last node a BST search for `key` visits in the set's current tree, or nil if empty.
private func lastVisited(_ set: SplaySet, _ key: Int) -> Int? {
    var node = set.root
    var last: Int? = nil
    while let current = node {
        last = current.key
        if key == current.key { break }
        node = key < current.key ? current.left : current.right
    }
    return last
}

private struct Dice {
    var state: UInt64
    mutating func roll(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int(state >> 33) % bound
    }
}

@Suite struct SplayingSetTests {
    @Test("Sorted inserts make a chain; accessing the bottom halves it, twice")
    func zigZigHalves() {
        let set = SplaySet()
        var badInserts = 0
        for key in 1...500 where !set.insert(key) || set.root?.key != key {
            badInserts += 1
        }
        #expect(badInserts == 0, "each new key should be inserted and end up at the root")
        #expect(set.count == 500)
        #expect(set.height == 500)
        #expect(set.contains(1))
        #expect(set.root?.key == 1)
        #expect(set.height <= 300, "after accessing 1: height \(set.height), but splaying should leave about 250")
        #expect(set.contains(2))
        #expect(set.root?.key == 2)
        #expect(set.height <= 200, "after accessing 2: height \(set.height), but splaying should leave about 125")
        #expect(set.sortedKeys == Array(1...500))
    }

    @Test("A miss splays the last node visited")
    func missSplaysLastVisited() {
        let set = SplaySet()
        for key in [10, 20, 30] { set.insert(key) }
        let expected = lastVisited(set, 25)
        #expect(!set.contains(25))
        #expect(set.root?.key == expected)
        #expect([20, 30].contains(set.root?.key ?? 0))
        #expect(!set.contains(-100))
        #expect(set.root?.key == 10)
        #expect(!set.contains(100))
        #expect(set.root?.key == 30)
    }

    @Test("Duplicates are ignored, but still move to the root")
    func duplicates() {
        let set = SplaySet()
        #expect(set.insert(5))
        #expect(!set.insert(5))
        #expect(set.count == 1)
        set.insert(9)
        set.insert(1)
        #expect(!set.insert(9))
        #expect(set.root?.key == 9)
        #expect(set.count == 3)
        #expect(set.sortedKeys == [1, 5, 9])
    }

    @Test("Removing")
    func removing() {
        let set = SplaySet()
        for key in [10, 20, 30] { set.insert(key) }
        #expect(set.remove(20))
        #expect(set.root?.key == 10)                              // the largest key below 20
        #expect(set.sortedKeys == [10, 30])
        #expect(!set.remove(20))
        #expect(set.count == 2)
        #expect(set.remove(10))                                   // nothing smaller: 30 is all that's left
        #expect(set.root?.key == 30)
        #expect(set.remove(30))
        #expect(set.root == nil)
        #expect(set.count == 0)
        #expect(!set.remove(30))
        #expect(!set.contains(30))
    }

    @Test("An empty set")
    func empty() {
        let set = SplaySet()
        #expect(!set.contains(0))
        #expect(!set.remove(0))
        #expect(set.root == nil)
        #expect(set.count == 0)
        #expect(set.sortedKeys == [])
    }

    @Test("Extremes of Int")
    func extremes() {
        let set = SplaySet()
        for key in [0, Int.max, Int.min] { set.insert(key) }
        #expect(set.contains(Int.max))
        #expect(set.contains(Int.min))
        #expect(set.sortedKeys == [Int.min, 0, Int.max])
        #expect(set.remove(Int.max))
        #expect(set.root?.key == 0)
    }

    @Test("Random operations: the right answers, the right root, and a valid BST")
    func randomOperations() {
        var dice = Dice(state: 41)
        var failures: [String] = []
        for round in 0..<40 {
            let set = SplaySet()
            var reference = Set<Int>()
            let range = 10 + round * 5
            for step in 0..<400 {
                let key = dice.roll(range)
                let kind = dice.roll(3)
                let path = lastVisited(set, key)
                let present = reference.contains(key)
                switch kind {
                case 0:
                    if set.insert(key) == present { failures.append("insert(\(key)) gave the wrong result") }
                    reference.insert(key)
                    if set.root?.key != key { failures.append("insert(\(key)) left \(String(describing: set.root?.key)) at the root") }
                case 1:
                    if set.contains(key) != present { failures.append("contains(\(key)) gave the wrong result") }
                    if set.root?.key != path { failures.append("contains(\(key)): root \(String(describing: set.root?.key)), expected \(String(describing: path))") }
                default:
                    if set.remove(key) != present { failures.append("remove(\(key)) gave the wrong result") }
                    reference.remove(key)
                    if present, let below = reference.filter({ $0 < key }).max(), set.root?.key != below {
                        failures.append("remove(\(key)): root \(String(describing: set.root?.key)), expected \(below)")
                    }
                    if !present && set.root?.key != path {
                        failures.append("remove(\(key)) missed: root \(String(describing: set.root?.key)), expected \(String(describing: path))")
                    }
                }
                if set.count != reference.count { failures.append("count \(set.count), expected \(reference.count)") }
                if step % 50 == 0 && set.sortedKeys != reference.sorted() { failures.append("keys \(set.sortedKeys), expected \(reference.sorted())") }
                if failures.count >= 3 { break }
            }
            if failures.count >= 3 { break }
        }
        #expect(failures.isEmpty, "\(failures.prefix(3))")
    }

    @Test("Sequential access over a 500-node chain, then remove every other key")
    func sequential() {
        let set = SplaySet()
        for key in 1...500 { set.insert(key) }
        let missing = (1...500).filter { !set.contains($0) }
        #expect(missing.isEmpty, "contains said no to \(missing.prefix(5))…")
        #expect(set.root?.key == 500)
        let notRemoved = stride(from: 1, through: 500, by: 2).filter { !set.remove($0) }
        #expect(notRemoved.isEmpty, "remove said no to \(notRemoved.prefix(5))…")
        #expect(set.sortedKeys == Array(stride(from: 2, through: 500, by: 2)))
        #expect(set.count == 250)
    }

    @Test("200,000 random operations on up to 50,000 keys")
    func large() {
        var dice = Dice(state: 4_100)
        let set = SplaySet()
        var reference = Set<Int>()
        var wrong = 0
        for _ in 0..<200_000 {
            let key = dice.roll(50_000)
            switch dice.roll(4) {
            case 0, 1:
                if set.insert(key) != reference.insert(key).inserted { wrong += 1 }
            case 2:
                if set.contains(key) != reference.contains(key) { wrong += 1 }
            default:
                if set.remove(key) != (reference.remove(key) != nil) { wrong += 1 }
            }
        }
        #expect(wrong == 0)
        #expect(set.count == reference.count)
        #expect(set.sortedKeys == reference.sorted())
    }
}
