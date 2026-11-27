import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A B-tree node for the reference: keys and child indexes into a shared array of nodes.
private struct RefNode {
    var keys: [Int] = []
    var children: [Int] = []
}

/// The same rules written another way: nodes in an array, an explicit path from the root, and splits
/// done in a loop while walking back up that path.
private func referenceLevels(_ keys: [Int], _ maxKeys: Int) -> [[[Int]]] {
    guard !keys.isEmpty else { return [] }
    var nodes = [RefNode()]
    var root = 0
    for key in keys {
        var path: [(node: Int, slot: Int)] = []           // nodes visited, and the child taken from each
        var current = root
        var duplicate = false
        while true {
            var slot = 0                                  // the first key ≥ key, by a plain scan
            let size = nodes[current].keys.count
            while slot < size && nodes[current].keys[slot] < key { slot += 1 }
            if slot < size && nodes[current].keys[slot] == key { duplicate = true; break }
            if nodes[current].children.isEmpty {
                nodes[current].keys.insert(key, at: slot)
                break
            }
            path.append((current, slot))
            current = nodes[current].children[slot]
        }
        if duplicate { continue }
        // Split upwards while the current node is overfull
        while nodes[current].keys.count > maxKeys {
            let mid = nodes[current].keys.count / 2
            let median = nodes[current].keys[mid]
            var right = RefNode()
            right.keys = Array(nodes[current].keys[(mid + 1)...])
            nodes[current].keys = Array(nodes[current].keys[..<mid])
            if !nodes[current].children.isEmpty {
                right.children = Array(nodes[current].children[(mid + 1)...])
                nodes[current].children = Array(nodes[current].children[...mid])
            }
            nodes.append(right)
            let rightIndex = nodes.count - 1
            if let (parent, slot) = path.popLast() {
                nodes[parent].keys.insert(median, at: slot)
                nodes[parent].children.insert(rightIndex, at: slot + 1)
                current = parent
            } else {
                nodes.append(RefNode(keys: [median], children: [current, rightIndex]))
                root = nodes.count - 1
                break
            }
        }
    }
    var result: [[[Int]]] = []
    var level = [root]
    while !level.isEmpty {
        result.append(level.map { nodes[$0].keys })
        level = level.flatMap { nodes[$0].children }
    }
    return result
}

/// Checks the B-tree rules on a result: sizes, sorted keys, separators, and leaves all at one depth
/// (every node on the last level has no children, every other node has keys + 1 children).
private func isValidBTree(_ levels: [[[Int]]], maxKeys: Int) -> Bool {
    for (depth, level) in levels.enumerated() {
        for node in level {
            guard !node.isEmpty, node.count <= maxKeys, zip(node, node.dropFirst()).allSatisfy({ $0 < $1 }) else { return false }
            if depth > 0 && node.count < maxKeys / 2 { return false }
        }
        if depth + 1 < levels.count {
            let childCount = level.reduce(0) { $0 + $1.count + 1 }
            if levels[depth + 1].count != childCount { return false }
        }
    }
    return true
}

private struct Dice {
    var state: UInt64
    mutating func roll(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int(state >> 33) % bound
    }
}

@Suite struct BTreeLevelsBuilderTests {
    @Test("The examples")
    func examples() {
        #expect(BTreeLevelsBuilder.levels(afterInserting: [1, 2, 3, 4], maxKeys: 3) == [[[3]], [[1, 2], [4]]])
        #expect(BTreeLevelsBuilder.levels(afterInserting: Array(1...13), maxKeys: 3)
                == [[[9]], [[3, 6], [12]], [[1, 2], [4, 5], [7, 8], [10, 11], [13]]])
        #expect(BTreeLevelsBuilder.levels(afterInserting: [10, 20, 30], maxKeys: 2) == [[[20]], [[10], [30]]])
        #expect(BTreeLevelsBuilder.levels(afterInserting: [5, 1, 9, 5], maxKeys: 4) == [[[1, 5, 9]]])
        #expect(BTreeLevelsBuilder.levels(afterInserting: [], maxKeys: 3) == [])
    }

    @Test("Every step of the lesson's 13 inserts", arguments: 1...13)
    func lessonSteps(count: Int) {
        #expect(BTreeLevelsBuilder.levels(afterInserting: Array(1...count), maxKeys: 3) == referenceLevels(Array(1...count), 3))
    }

    @Test("More hand-checked trees")
    func handChecked() {
        // An even-sized overflow: 5 keys with maxKeys 4 send the key at index 2 up
        #expect(BTreeLevelsBuilder.levels(afterInserting: [50, 10, 40, 20, 30], maxKeys: 4) == [[[30]], [[10, 20], [40, 50]]])
        // A split into a middle child: 25 lands between 20 and 30
        #expect(BTreeLevelsBuilder.levels(afterInserting: [10, 20, 30, 40, 25, 26], maxKeys: 2)
                == [[[20, 30]], [[10], [25, 26], [40]]])
        #expect(BTreeLevelsBuilder.levels(afterInserting: [7, 7, 7], maxKeys: 2) == [[[7]]])
        #expect(BTreeLevelsBuilder.levels(afterInserting: [Int.max, Int.min, 0], maxKeys: 2) == [[[0]], [[Int.min], [Int.max]]])
    }

    @Test("Random keys and sizes match the reference and obey the rules")
    func manyRandom() {
        var dice = Dice(state: 40)
        var failures: [String] = []
        for round in 0..<400 {
            let maxKeys = 2 + round % 6
            let count = dice.roll(120)
            let keys = (0..<count).map { _ in dice.roll(150) - 50 }
            let expected = referenceLevels(keys, maxKeys)
            let actual = BTreeLevelsBuilder.levels(afterInserting: keys, maxKeys: maxKeys)
            if failures.count < 3 && (actual != expected || !isValidBTree(actual, maxKeys: maxKeys)) {
                failures.append("maxKeys \(maxKeys), keys \(keys): got \(actual), expected \(expected)")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("30,000 keys: sorted with maxKeys 2, shuffled with maxKeys 3 and 64")
    func large() {
        let n = 30_000
        let sorted = BTreeLevelsBuilder.levels(afterInserting: Array(0..<n), maxKeys: 2)
        #expect(isValidBTree(sorted, maxKeys: 2))
        #expect(sorted == referenceLevels(Array(0..<n), 2))
        let shuffled = (0..<n).map { ($0 * 7_919) % n }
        for maxKeys in [3, 64] {
            let actual = BTreeLevelsBuilder.levels(afterInserting: shuffled, maxKeys: maxKeys)
            #expect(isValidBTree(actual, maxKeys: maxKeys), "maxKeys \(maxKeys)")
            #expect(actual.flatMap { $0 }.reduce(0) { $0 + $1.count } == n, "maxKeys \(maxKeys): every key once")
            #expect(actual == referenceLevels(shuffled, maxKeys), "maxKeys \(maxKeys)")
        }
    }
}
