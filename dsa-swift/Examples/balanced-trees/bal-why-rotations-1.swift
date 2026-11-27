// Generated from src/dsa/content/lessons/balanced-trees/bal-why-rotations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    let value: Int
    var left: Node?
    var right: Node?
    init(_ value: Int) { self.value = value }
}

// A plain BST insert with a loop, so a very deep tree can't overflow the stack
func insert(_ value: Int, into root: inout Node?) {
    guard var node = root else {
        root = Node(value)
        return
    }
    while true {
        if value < node.value {
            guard let next = node.left else { node.left = Node(value); return }
            node = next
        } else {
            guard let next = node.right else { node.right = Node(value); return }
            node = next
        }
    }
}

// How many nodes a search visits before it finds value
func visits(toFind value: Int, in root: Node?) -> Int {
    var count = 0
    var current = root
    while let node = current {
        count += 1
        if value == node.value { break }
        current = value < node.value ? node.left : node.right
    }
    return count
}

func report(_ label: String, _ order: [Int]) {
    var root: Node? = nil
    for value in order {
        insert(value, into: &root)
    }
    let costs = order.map { visits(toFind: $0, in: root) }
    let average = Double(costs.reduce(0, +)) / Double(costs.count)
    print("\(label): worst search \(costs.max()!), average \(average)")
}

// The middle value first, then the middles of each half, and so on
func middleFirst(_ low: Int, _ high: Int) -> [Int] {
    guard low <= high else { return [] }
    let mid = (low + high) / 2
    return [mid] + middleFirst(low, mid - 1) + middleFirst(mid + 1, high)
}

let n = 1_000
report("sorted      ", Array(0..<n))
report("scrambled   ", (0..<n).map { ($0 * 7_919) % n })
report("middle first", middleFirst(0, n - 1))
