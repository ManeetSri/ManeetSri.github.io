// Generated from src/dsa/content/lessons/fenwick/bit-point-update.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A Fenwick tree with an O(n) build and a 0-indexed API (1-indexed inside)
struct Fenwick {
    private var tree: [Int]                       // tree[i] covers positions i - lowbit(i) + 1 ... i

    init(_ items: [Int]) {
        tree = [0] + items                        // each slot starts with its own item...
        for i in 1..<tree.count {
            let parent = i + (i & -i)             // ...then passes its finished total up once
            if parent < tree.count {
                tree[parent] += tree[i]
            }
        }
    }

    /// Adds delta to items[index].
    mutating func add(_ delta: Int, at index: Int) {
        var i = index + 1
        while i < tree.count {
            tree[i] += delta
            i += i & -i
        }
    }

    /// The sum of items[0...index]. An index of -1 gives 0.
    func prefixSum(through index: Int) -> Int {
        var i = index + 1
        var total = 0
        while i > 0 {
            total += tree[i]
            i -= i & -i
        }
        return total
    }

    /// The sum of items[left...right].
    func sum(_ left: Int, _ right: Int) -> Int {
        prefixSum(through: right) - prefixSum(through: left - 1)
    }
}

var scores = Fenwick([3, 2, -1, 6, 5, 4, -3, 3])
print(scores.sum(0, 6), scores.sum(2, 5), scores.sum(7, 7))
scores.add(2, at: 2)
print(scores.sum(0, 6), scores.sum(2, 2))

// Check every range against plain addition, after each of 1,000 updates on 11 items
var items = [4, -2, 8, 0, 3, 3, 9, -5, 1, 6, 2]
var checked = Fenwick(items)
var mismatches = 0
for step in 0..<1_000 {
    let index = (step * 7) % items.count
    let delta = (step * 13) % 21 - 10
    items[index] += delta
    checked.add(delta, at: index)
    for left in 0..<items.count {
        for right in left..<items.count where checked.sum(left, right) != items[left...right].reduce(0, +) {
            mismatches += 1
        }
    }
}
print("mismatches:", mismatches)
