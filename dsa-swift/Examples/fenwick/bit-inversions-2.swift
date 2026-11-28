// Generated from src/dsa/content/lessons/fenwick/bit-inversions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// For each item, how many later items are smaller: scan right to left
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

func smallerAfter(_ items: [Int]) -> [Int] {
    let distinct = Array(Set(items)).sorted()
    var rankOf: [Int: Int] = [:]
    for (offset, value) in distinct.enumerated() {
        rankOf[value] = offset + 1
    }
    var later = Fenwick(count: distinct.count)               // counts of the items to the right, by rank
    var result = Array(repeating: 0, count: items.count)
    for index in stride(from: items.count - 1, through: 0, by: -1) {
        let rank = rankOf[items[index]]!
        result[index] = later.prefixSum(rank - 1)            // strictly smaller: ranks 1...rank - 1
        later.add(1, at: rank)
    }
    return result
}

let counts = smallerAfter([7, 3, 9, 3, 1, 8])
print(counts, counts.reduce(0, +))
print(smallerAfter([]), smallerAfter([4, 4, 4]), smallerAfter([-5, -10, 20]))
