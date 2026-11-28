import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct LinearBuildRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FenwickLinearBuildTests {
    /// The Fenwick array straight from the definition: slot i sums positions i − lowbit(i) + 1 ... i
    private func definition(_ items: [Int]) -> [Int] {
        var tree = [0]
        for i in stride(from: 1, through: items.count, by: 1) {
            tree.append(items[(i - (i & -i))..<i].reduce(0, +))
        }
        return tree
    }

    @Test("The examples", arguments: [
        ([5, 3, 7, 9, 6, 4, 1, 2], [0, 5, 8, 7, 24, 6, 10, 1, 37]),
        ([2, -1, 4], [0, 2, 1, 4]),
        ([], [0]),
        ([42], [0, 42]),
    ])
    func examples(items: [Int], tree: [Int]) {
        #expect(FenwickLinearBuild.build(items) == tree)
        #expect(FenwickLinearBuild.items(from: tree) == items)
    }

    @Test("Matches the definition for every length from 0 to 70")
    func everyLength() {
        var random = LinearBuildRandom(seed: 61)
        for n in 0...70 {
            let items = (0..<n).map { _ in Int.random(in: -1_000...1_000, using: &random) }
            let expected = definition(items)
            #expect(FenwickLinearBuild.build(items) == expected, "n = \(n)")
            #expect(FenwickLinearBuild.items(from: expected) == items, "n = \(n)")
        }
    }

    @Test("Powers of two: the last slot holds the total")
    func powersOfTwo() {
        for power in 0...12 {
            let n = 1 << power
            let items = (1...n).map { $0 }
            let tree = FenwickLinearBuild.build(items)
            #expect(tree.count == n + 1)
            #expect(tree.last == n * (n + 1) / 2, "n = \(n)")
        }
    }

    @Test("A million items, built and recovered")
    func large() {
        var random = LinearBuildRandom(seed: 1_000_000)
        let items = (0..<1_000_000).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        let tree = FenwickLinearBuild.build(items)
        #expect(tree.count == items.count + 1)
        guard tree.count == items.count + 1 else { return }
        // Check a few slots against the definition, including the big ones
        for slot in [1, 2, 3, 512, 524_288, 999_999, 1_000_000] {
            let low = slot - (slot & -slot)
            #expect(tree[slot] == items[low..<slot].reduce(0, +), "slot \(slot)")
        }
        // A prefix query over the built tree gives the true prefix sum
        var total = 0
        var i = items.count
        while i > 0 {
            total += tree[i]
            i -= i & -i
        }
        #expect(total == items.reduce(0, +))
        #expect(FenwickLinearBuild.items(from: tree) == items)
    }
}
