// Generated from src/dsa/content/lessons/advanced-structures/as-skip-list.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

final class SkipList {
    final class Node {
        let value: Int
        var next: [Node?]                        // next[level]: the following node on that level

        init(_ value: Int, height: Int) {
            self.value = value
            next = Array(repeating: nil, count: height)
        }
    }

    let maxHeight = 32
    private let head: Node                       // a sentinel as tall as any node can be
    private var height = 1                       // levels in use
    private var generator: SeededGenerator
    private(set) var count = 0
    var steps = 0                                // moves made by searches, to measure the cost

    init(seed: UInt64) {
        head = Node(Int.min, height: maxHeight)
        generator = SeededGenerator(state: seed)
    }

    private func randomHeight() -> Int {
        var height = 1
        while height < maxHeight && generator.next() & 1 == 1 {
            height += 1
        }
        return height
    }

    // The last node before value on every level: where the search dropped down
    private func predecessors(of value: Int) -> [Node] {
        var result = Array(repeating: head, count: maxHeight)
        var current = head
        for level in stride(from: height - 1, through: 0, by: -1) {
            while let next = current.next[level], next.value < value {
                current = next                   // move right on this level
                steps += 1
            }
            result[level] = current              // then drop down a level
            steps += 1
        }
        return result
    }

    func contains(_ value: Int) -> Bool {
        predecessors(of: value)[0].next[0]?.value == value
    }

    @discardableResult
    func insert(_ value: Int) -> Bool {
        let before = predecessors(of: value)
        if before[0].next[0]?.value == value { return false }
        let node = Node(value, height: randomHeight())
        height = max(height, node.next.count)
        for level in 0..<node.next.count {       // splice it in on each of its levels
            node.next[level] = before[level].next[level]
            before[level].next[level] = node
        }
        count += 1
        return true
    }

    @discardableResult
    func remove(_ value: Int) -> Bool {
        let before = predecessors(of: value)
        guard let node = before[0].next[0], node.value == value else { return false }
        for level in 0..<node.next.count {       // unlink it from each of its levels
            before[level].next[level] = node.next[level]
        }
        while height > 1 && head.next[height - 1] == nil {
            height -= 1                          // the tallest node may have gone
        }
        count -= 1
        return true
    }

    // Each level as a list of values, top level first
    func levels() -> [[Int]] {
        (0..<height).reversed().map { level in
            var values: [Int] = []
            var current = head.next[level]
            while let node = current {
                values.append(node.value)
                current = node.next[level]
            }
            return values
        }
    }
}

let list = SkipList(seed: 99)
for value in [30, 10, 50, 20, 60, 40, 70, 90, 80] {
    list.insert(value)
}
let levels = list.levels()
for (index, level) in levels.enumerated() {
    print("level \(levels.count - index):", level)
}
print("contains 40?", list.contains(40), " contains 45?", list.contains(45))
list.remove(40)
print("after removing 40:", list.levels().last!, "count:", list.count)

// Sorted input, the worst case for a plain BST: average moves per search
for n in [1_000, 10_000, 100_000] {
    let big = SkipList(seed: 7)
    for value in 0..<n {
        big.insert(value)
    }
    big.steps = 0
    for value in stride(from: 0, to: n, by: 7) {
        _ = big.contains(value)
    }
    let searches = (n + 6) / 7
    print("n = \(n): \(big.steps / searches) moves per search")
}
