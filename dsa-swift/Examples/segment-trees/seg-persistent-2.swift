// Generated from src/dsa/content/lessons/segment-trees/seg-persistent.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Kth smallest in items[l...r]: a persistent tree of value counts for every prefix of the array
struct PrefixCountTrees {
    private var lefts = [0], rights = [0], counts = [0]   // node 0: the empty tree
    private var roots = [0]                       // roots[i] counts the values in items[0..<i]
    private let values: [Int]                     // the distinct values, sorted: rank r is values[r]

    init(_ items: [Int]) {
        values = Array(Set(items)).sorted()
        let rankOf = Dictionary(uniqueKeysWithValues: values.enumerated().map { ($0.element, $0.offset) })
        for item in items {
            roots.append(insert(roots.last!, 0, values.count - 1, rankOf[item]!))
        }
    }

    var nodeCount: Int { counts.count }

    // A copy of the path to `rank`, with one more value counted there
    private mutating func insert(_ node: Int, _ low: Int, _ high: Int, _ rank: Int) -> Int {
        var left = lefts[node], right = rights[node]
        if low < high {
            let mid = (low + high) / 2
            if rank <= mid { left = insert(left, low, mid, rank) } else { right = insert(right, mid + 1, high, rank) }
        }
        lefts.append(left)
        rights.append(right)
        counts.append(counts[node] + 1)
        return counts.count - 1
    }

    /// The kth smallest (from 1) of items[left...right].
    func kthSmallest(_ k: Int, _ left: Int, _ right: Int) -> Int {
        var newer = roots[right + 1], older = roots[left]  // counts in left...right: newer minus older
        var low = 0, high = values.count - 1
        var k = k
        while low < high {
            let mid = (low + high) / 2
            let inLeftHalf = counts[lefts[newer]] - counts[lefts[older]]
            if k <= inLeftHalf {                  // the answer's rank is in low...mid
                newer = lefts[newer]
                older = lefts[older]
                high = mid
            } else {                              // skip the smaller values and go right
                k -= inLeftHalf
                newer = rights[newer]
                older = rights[older]
                low = mid + 1
            }
        }
        return values[low]
    }
}

let items = [5, 1, 7, 3, 8, 2, 6, 4]
let trees = PrefixCountTrees(items)
print(trees.kthSmallest(1, 1, 6), trees.kthSmallest(3, 1, 6), trees.kthSmallest(6, 1, 6))
print("nodes:", trees.nodeCount)

var mismatches = 0
for left in 0..<items.count {
    for right in left..<items.count {
        let range = items[left...right].sorted()
        for k in 1...range.count where trees.kthSmallest(k, left, right) != range[k - 1] {
            mismatches += 1
        }
    }
}
print("mismatches:", mismatches)
let repeated = PrefixCountTrees([4, 4, 1, 4, 9, 1])
print(repeated.kthSmallest(2, 0, 5), repeated.kthSmallest(3, 0, 5), repeated.kthSmallest(2, 3, 5))
