// Generated from src/dsa/content/lessons/fenwick/bit-range-updates.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Range add, point query: a Fenwick tree over the difference array
struct Fenwick {
    private var tree: [Int]
    init(count: Int) { tree = Array(repeating: 0, count: count + 1) }

    /// Adds delta at position (1-indexed); positions past the end are ignored.
    mutating func add(_ delta: Int, at position: Int) {
        var i = position
        while i < tree.count {
            tree[i] += delta
            i += i & -i
        }
    }

    /// The sum of positions 1...position.
    func prefixSum(_ position: Int) -> Int {
        var i = position, total = 0
        while i > 0 {
            total += tree[i]
            i -= i & -i
        }
        return total
    }
}

let n = 8
var changes = Fenwick(count: n)                   // changes holds d, where item p = d[1] + ... + d[p]
func addToRange(_ delta: Int, _ left: Int, _ right: Int) {
    changes.add(delta, at: left)                  // from left onwards, everything rises
    changes.add(-delta, at: right + 1)            // ...and stops rising after right
}
func item(_ position: Int) -> Int { changes.prefixSum(position) }

addToRange(5, 2, 6)
addToRange(-2, 4, 8)
addToRange(1, 1, 1)
print((1...n).map(item))
