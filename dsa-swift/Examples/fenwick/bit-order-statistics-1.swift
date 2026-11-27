// Generated from src/dsa/content/lessons/fenwick/bit-order-statistics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A multiset of small integers: counts by value in a Fenwick tree, kth smallest by binary lifting
struct ScoreBag {
    private var tree: [Int]                       // tree[v] covers the counts of values v - lowbit(v) + 1 ... v
    private(set) var count = 0                    // how many scores are in the bag

    init(maxScore: Int) {
        tree = Array(repeating: 0, count: maxScore + 1)
    }

    mutating func insert(_ score: Int) {
        change(score, by: 1)
        count += 1
    }

    mutating func remove(_ score: Int) {          // the caller checks the score is in the bag
        change(score, by: -1)
        count -= 1
    }

    private mutating func change(_ score: Int, by delta: Int) {
        var i = score
        while i < tree.count {
            tree[i] += delta
            i += i & -i
        }
    }

    /// How many scores are at most `score`.
    func countAtMost(_ score: Int) -> Int {
        var i = score, total = 0
        while i > 0 {
            total += tree[i]
            i -= i & -i
        }
        return total
    }

    /// The kth smallest score, counting from 1. Requires 1 <= k <= count.
    func kthSmallest(_ k: Int, showingSteps: Bool = false) -> Int {
        var position = 0                          // every value up to here holds fewer than k scores
        var remaining = k                         // how many more scores we still need to pass
        var step = 1
        while step * 2 < tree.count { step *= 2 }  // the largest power of two that fits
        while step > 0 {
            let next = position + step
            if next < tree.count && tree[next] < remaining {
                position = next                   // values position+1...next hold too few: skip them all
                remaining -= tree[next]
                if showingSteps { print("  jump to \(position), still need \(remaining)") }
            } else if showingSteps {
                print("  stay at \(position): values \(position + 1)...\(min(next, tree.count - 1)) are enough")
            }
            step /= 2
        }
        return position + 1                       // the first value where the running count reaches k
    }
}

var bag = ScoreBag(maxScore: 10)
for score in [4, 7, 7, 2, 9] {
    bag.insert(score)
}
print((1...bag.count).map { bag.kthSmallest($0) })
print("the 4th smallest, step by step:")
print(bag.kthSmallest(4, showingSteps: true))
bag.remove(7)
bag.insert(1)
print((1...bag.count).map { bag.kthSmallest($0) }, "median:", bag.kthSmallest((bag.count + 1) / 2))
print("scores at most 5:", bag.countAtMost(5))
