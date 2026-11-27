// Generated from src/dsa/content/lessons/bst/bst-degenerate.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TreeNode {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?
    init(_ value: Int) { self.value = value }
}

// Inserts value and returns how many nodes it was compared with on the way down
func insert(_ value: Int, into root: inout TreeNode?) -> Int {
    guard var node = root else {
        root = TreeNode(value)
        return 0
    }
    var comparisons = 1
    while true {
        if value < node.value {
            guard let left = node.left else { node.left = TreeNode(value); return comparisons }
            node = left
        } else {
            guard let right = node.right else { node.right = TreeNode(value); return comparisons }
            node = right
        }
        comparisons += 1
    }
}

func height(_ root: TreeNode?) -> Int {
    var levels = 0
    var level = [root].compactMap { $0 }
    while !level.isEmpty {
        levels += 1
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return levels
}

// The same "random" order every run: a Fisher–Yates shuffle driven by a fixed formula
func scrambled(_ n: Int) -> [Int] {
    var values = Array(1...n)
    var state: UInt64 = 2024
    for i in stride(from: n - 1, to: 0, by: -1) {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        values.swapAt(i, Int((state >> 33) % UInt64(i + 1)))
    }
    return values
}

// The middle, then the middle of each half, and so on
func middleFirst(_ low: Int, _ high: Int, into order: inout [Int]) {
    guard low <= high else { return }
    let mid = (low + high) / 2
    order.append(mid)
    middleFirst(low, mid - 1, into: &order)
    middleFirst(mid + 1, high, into: &order)
}

for n in [100, 1_000, 3_000] {
    var balanced: [Int] = []
    middleFirst(1, n, into: &balanced)
    for (name, order) in [("sorted", Array(1...n)), ("scrambled", scrambled(n)), ("middle first", balanced)] {
        var root: TreeNode? = nil
        var total = 0
        for value in order {
            total += insert(value, into: &root)
        }
        print("n = \(n), \(name): height \(height(root)), about \(total / n) comparisons per insert")
    }
}
