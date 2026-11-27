import Testing
import DSAKit

@Suite struct FenwickTreeTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("Prefix sums, range sums and single elements")
    func sums() {
        let tree = FenwickTree([3, 2, -1, 6, 5, 4, -3, 3])
        #expect(tree.count == 8)
        #expect(tree.prefixSum(through: 0) == 3)
        #expect(tree.prefixSum(through: 6) == 16)
        #expect(tree.prefixSum(upTo: 0) == 0)
        #expect(tree.prefixSum(upTo: 8) == 19)
        #expect(tree.sum(in: 2...4) == 10)
        #expect(tree.sum(in: 2..<5) == 10)
        #expect(tree.sum(in: ..<2) == 5)
        #expect(tree.sum(in: 6...) == 0)
        #expect(tree.sum(in: ...) == 19)
        #expect(tree[3] == 6)
        #expect(tree[7] == 3)
        #expect(tree.values == [3, 2, -1, 6, 5, 4, -3, 3])
    }

    @Test("Additions and set")
    func updates() {
        var tree: FenwickTree = [3, 2, -1, 6, 5]
        tree.add(10, at: 1)
        #expect(tree.sum(in: 1...3) == 17)
        #expect(tree[1] == 12)
        tree.set(0, at: 3)
        #expect(tree.values == [3, 12, -1, 0, 5])
        tree.add(-5, at: 4)
        #expect(tree.sum(in: ...) == 14)
        #expect(tree.description == "FenwickTree([3, 12, -1, 0, 0])")
    }

    @Test("Empty ranges, an empty tree and a single element")
    func edges() {
        let tree = FenwickTree([4, 5, 6])
        #expect(tree.sum(in: 0..<0) == 0)
        #expect(tree.sum(in: 3..<3) == 0)
        #expect(tree.sum(in: 1..<1) == 0)

        let empty = FenwickTree(count: 0)
        #expect(empty.isEmpty)
        #expect(empty.prefixSum(upTo: 0) == 0)
        #expect(empty.sum(in: ...) == 0)
        #expect(empty.values == [])
        #expect(empty.lowerBound(prefix: 1) == 0)
        #expect(FenwickTree([]).count == 0)

        var single = FenwickTree(count: 1)
        single.add(7, at: 0)
        #expect(single.prefixSum(through: 0) == 7)
        #expect(single.lowerBound(prefix: 7) == 0)
        #expect(single.lowerBound(prefix: 8) == 1)
    }

    @Test("The O(n) build matches one addition per element", arguments: [1, 2, 3, 8, 9, 31, 64, 1_000])
    func buildMatchesAdditions(count: Int) {
        var steps = Steps(seed: UInt64(count))
        let values = (0..<count).map { _ in steps.next(below: 201) - 100 }
        var added = FenwickTree(count: count)
        for (index, value) in values.enumerated() {
            added.add(value, at: index)
        }
        let built = FenwickTree(values)
        for index in 0..<count {
            #expect(built.prefixSum(through: index) == added.prefixSum(through: index))
        }
        #expect(built.values == values)
        #expect(added.values == values)
    }

    @Test("lowerBound finds where the running total first reaches a target")
    func lowerBound() {
        // Counts of the values 0...7 in a multiset: two 1s, one 3, three 4s, one 7
        let counts = FenwickTree([0, 2, 0, 1, 3, 0, 0, 1])
        #expect(counts.lowerBound(prefix: 0) == 0)
        #expect(counts.lowerBound(prefix: 1) == 1)
        #expect(counts.lowerBound(prefix: 2) == 1)
        #expect(counts.lowerBound(prefix: 3) == 3)
        #expect(counts.lowerBound(prefix: 4) == 4)
        #expect(counts.lowerBound(prefix: 6) == 4)
        #expect(counts.lowerBound(prefix: 7) == 7)
        #expect(counts.lowerBound(prefix: 8) == 8)        // more than there are: count
        #expect(counts.lowerBound(prefix: -3) == 0)
    }

    @Test("lowerBound agrees with a linear scan", arguments: [1, 2, 5, 16, 17, 100, 1_000])
    func lowerBoundRandom(count: Int) {
        var steps = Steps(seed: UInt64(count * 7))
        var model = (0..<count).map { _ in steps.next(below: 4) }
        var tree = FenwickTree(model)
        var mismatches = 0
        for _ in 0..<2_000 {
            let index = steps.next(below: count)
            let delta = steps.next(below: 3)
            model[index] += delta
            tree.add(delta, at: index)
            let total = model.reduce(0, +)
            let target = steps.next(below: total + 2)
            var running = 0
            var expected = count
            for position in 0..<count {
                running += model[position]
                if running >= target {
                    expected = position
                    break
                }
            }
            if target <= 0 { expected = 0 }
            if tree.lowerBound(prefix: target) != expected { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("Thousands of random updates and queries agree with a plain array", arguments: [1, 2, 7, 64, 100, 1_000])
    func randomAgainstArray(count: Int) {
        var steps = Steps(seed: UInt64(count + 99))
        var model = (0..<count).map { _ in steps.next(below: 2_001) - 1_000 }
        var tree = FenwickTree(model)
        var mismatches = 0
        for _ in 0..<5_000 {
            if steps.next(below: 2) == 0 {
                let index = steps.next(below: count)
                let delta = steps.next(below: 2_001) - 1_000
                model[index] += delta
                tree.add(delta, at: index)
            } else {
                let a = steps.next(below: count + 1)
                let b = steps.next(below: count + 1)
                let range = min(a, b)..<max(a, b)
                if tree.sum(in: range) != model[range].reduce(0, +) { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
        #expect(tree.values == model)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        let original: FenwickTree = [1, 2, 3]
        var copy = original
        copy.add(10, at: 0)
        #expect(original.sum(in: ...) == 6)
        #expect(copy.sum(in: ...) == 16)
    }

    @Test("100,000 elements and 100,000 operations")
    func large() {
        let count = 100_000
        var tree = FenwickTree(count: count)
        for index in 0..<count {
            tree.add(index % 3, at: index)
        }
        #expect(tree.sum(in: ...) == (0..<count).reduce(0) { $0 + $1 % 3 })
        var total = 0
        for start in 0..<50_000 {
            total += tree.sum(in: start..<(start + 3))
        }
        #expect(total == 50_000 * 3)
        // Order statistics over 100,000 ones: the kth smallest position is k - 1
        let ones = FenwickTree(Array(repeating: 1, count: count))
        #expect(ones.lowerBound(prefix: 1) == 0)
        #expect(ones.lowerBound(prefix: 54_321) == 54_320)
        #expect(ones.lowerBound(prefix: count) == count - 1)
    }
}
