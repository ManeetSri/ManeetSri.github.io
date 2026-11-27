// Generated from src/dsa/content/lessons/segment-trees/seg-build-query-update.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The bottom-up segment tree: leaves in tree[n..<2n], half-open ranges, no recursion
struct MinTree {
    private var tree: [Int]
    private let n: Int

    init(_ items: [Int]) {
        n = items.count
        tree = Array(repeating: Int.max, count: n) + items           // leaves at n..<2n
        for node in stride(from: n - 1, through: 1, by: -1) {
            tree[node] = min(tree[2 * node], tree[2 * node + 1])
        }
    }

    mutating func set(_ index: Int, to value: Int) {
        var node = index + n
        tree[node] = value
        while node > 1 {
            node /= 2
            tree[node] = min(tree[2 * node], tree[2 * node + 1])
        }
    }

    func minimum(_ range: Range<Int>) -> Int {
        var left = range.lowerBound + n
        var right = range.upperBound + n
        var best = Int.max
        while left < right {
            if left % 2 == 1 {                    // a right child: its parent sticks out on the left
                best = min(best, tree[left])
                left += 1
            }
            if right % 2 == 1 {                   // right - 1 is a left child: its parent sticks out on the right
                right -= 1
                best = min(best, tree[right])
            }
            left /= 2
            right /= 2
        }
        return best
    }
}

var prices = MinTree([7, 3, 9, 3, 5, 8])
print(prices.minimum(0..<6), prices.minimum(2..<3), prices.minimum(2..<2))
prices.set(1, to: 10)
prices.set(3, to: 10)
print(prices.minimum(0..<4), prices.minimum(4..<6))
