// Generated from src/dsa/content/lessons/fenwick/bit-inversions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Count inversions by scanning left to right with a Fenwick tree of value counts
struct Fenwick {
    private var tree: [Int]
    init(count: Int) { tree = Array(repeating: 0, count: count + 1) }

    mutating func add(_ delta: Int, at position: Int) {     // positions count from 1
        var i = position
        while i < tree.count {
            tree[i] += delta
            i += i & -i
        }
    }

    func prefixSum(_ position: Int) -> Int {                 // positions 1...position
        var i = position, total = 0
        while i > 0 {
            total += tree[i]
            i -= i & -i
        }
        return total
    }
}

// Coordinate compression: each value becomes its rank among the distinct values, counting from 1
func ranks(_ items: [Int]) -> [Int] {
    let distinct = Array(Set(items)).sorted()
    return items.map { value in
        var low = 0, high = distinct.count                   // lower bound: the first slot holding >= value
        while low < high {
            let mid = (low + high) / 2
            if distinct[mid] < value { low = mid + 1 } else { high = mid }
        }
        return low + 1
    }
}

func inversions(_ items: [Int]) -> Int {
    let rank = ranks(items)
    var seen = Fenwick(count: items.count)                   // seen counts the earlier items by rank
    var total = 0
    for (index, r) in rank.enumerated() {
        total += index - seen.prefixSum(r)                   // earlier items, minus those that are <= this one
        seen.add(1, at: r)
    }
    return total
}

let prices = [1_000_000_007, -3, 42, 42, 7, -3]
print(ranks(prices))
print(inversions(prices))

// Compare with checking every pair, on 500 small arrays
var state: UInt64 = 31
func next(_ limit: Int) -> Int {
    state = state &* 6364136223846793005 &+ 1442695040888963407
    return Int((state >> 33) % UInt64(limit))
}
var mismatches = 0
for _ in 0..<500 {
    let items = (0..<next(12)).map { _ in next(9) - 4 }
    var pairs = 0
    for i in items.indices {
        for j in items.indices where i < j && items[i] > items[j] { pairs += 1 }
    }
    if inversions(items) != pairs { mismatches += 1 }
}
print("mismatches:", mismatches)
