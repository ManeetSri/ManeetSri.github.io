// Generated from src/dsa/content/lessons/fenwick/bit-range-updates.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Range add, range sum: two Fenwick trees over the difference array
struct Fenwick {
    private var tree: [Int]
    init(count: Int) { tree = Array(repeating: 0, count: count + 1) }

    mutating func add(_ delta: Int, at position: Int) {
        var i = position
        while i < tree.count {
            tree[i] += delta
            i += i & -i
        }
    }

    func prefixSum(_ position: Int) -> Int {
        var i = position, total = 0
        while i > 0 {
            total += tree[i]
            i -= i & -i
        }
        return total
    }
}

struct RangeFenwick {
    private var plain: Fenwick                    // the changes d[j]
    private var weighted: Fenwick                 // the changes times their position, j × d[j]

    init(count: Int) {
        plain = Fenwick(count: count)
        weighted = Fenwick(count: count)
    }

    /// Adds delta to every item in left...right (1-indexed).
    mutating func add(_ delta: Int, _ left: Int, _ right: Int) {
        plain.add(delta, at: left)
        plain.add(-delta, at: right + 1)
        weighted.add(delta * left, at: left)
        weighted.add(-delta * (right + 1), at: right + 1)
    }

    /// The sum of items 1...position: (position + 1) × Σ d[j] − Σ j × d[j].
    func prefixSum(_ position: Int) -> Int {
        (position + 1) * plain.prefixSum(position) - weighted.prefixSum(position)
    }

    /// The sum of items left...right.
    func sum(_ left: Int, _ right: Int) -> Int {
        prefixSum(right) - prefixSum(left - 1)
    }
}

var days = RangeFenwick(count: 8)
days.add(5, 2, 6)                                 // items: [0, 5, 5, 5, 5, 5, 0, 0]
days.add(-2, 4, 8)                                // items: [0, 5, 5, 3, 3, 3, -2, -2]
print(days.sum(1, 8), days.sum(3, 5), days.sum(7, 7))

// Compare with a plain array over 3,000 random operations on 13 items
var items = Array(repeating: 0, count: 14)        // items[1...13]; items[0] is unused
var checked = RangeFenwick(count: 13)
var state: UInt64 = 61
func next(_ limit: Int) -> Int {
    state = state &* 6364136223846793005 &+ 1442695040888963407
    return Int((state >> 33) % UInt64(limit))
}
var mismatches = 0
for _ in 0..<3_000 {
    let a = next(13) + 1, b = next(13) + 1
    let left = min(a, b), right = max(a, b)
    if next(2) == 0 {
        let delta = next(21) - 10
        checked.add(delta, left, right)
        for p in left...right { items[p] += delta }
    } else if checked.sum(left, right) != items[left...right].reduce(0, +) {
        mismatches += 1
    }
}
print("mismatches:", mismatches)
