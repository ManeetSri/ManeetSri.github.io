// Generated from src/dsa/content/lessons/fenwick/bit-point-update.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A Fenwick tree for 8 items, built with one add per item. Positions count from 1; slot 0 is unused.
let items = [3, 2, -1, 6, 5, 4, -3, 3]
let n = items.count
var tree = Array(repeating: 0, count: n + 1)

func add(_ delta: Int, at position: Int) {
    var i = position
    while i <= n {
        tree[i] += delta
        i += i & -i                               // the next slot whose range covers position
    }
}

func prefixSum(_ position: Int) -> Int {          // the sum of items 1...position
    var i = position
    var total = 0
    while i > 0 {
        total += tree[i]
        i -= i & -i                               // the range just before this one
    }
    return total
}

for (offset, value) in items.enumerated() {
    add(value, at: offset + 1)
}
print("tree:", Array(tree[1...]))
print("first 7 items:", prefixSum(7))
print("items 3...6:", prefixSum(6) - prefixSum(2))
add(2, at: 3)                                     // item 3 goes from -1 to 1
print("first 7 items:", prefixSum(7))
