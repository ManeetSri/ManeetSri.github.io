import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct EditableSumsRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// A Fenwick tree: a different structure from the segment tree the solution uses, so it makes an
/// independent fast reference for the large test.
private struct EditableSumsFenwick {
    private var tree: [Int]
    private var values: [Int]

    init(_ values: [Int]) {
        self.values = values
        tree = [0] + values
        for i in 1..<tree.count where i + (i & -i) < tree.count {
            tree[i + (i & -i)] += tree[i]
        }
    }

    mutating func update(at index: Int, to value: Int) {
        let change = value - values[index]
        values[index] = value
        var i = index + 1
        while i < tree.count {
            tree[i] += change
            i += i & -i
        }
    }

    private func prefix(_ length: Int) -> Int {
        var i = length, total = 0
        while i > 0 {
            total += tree[i]
            i -= i & -i
        }
        return total
    }

    func sum(from start: Int, through end: Int) -> Int {
        prefix(end + 1) - prefix(start)
    }
}

@Suite struct EditableRangeSumsTests {
    @Test("The example from the statement")
    func example() {
        var table = EditableRangeSums.Table([4, -1, 6, 2, 5])
        #expect(table.sum(from: 0, through: 4) == 16)
        #expect(table.sum(from: 1, through: 3) == 7)
        table.update(at: 2, to: 0)
        #expect(table.sum(from: 1, through: 3) == 1)
        table.update(at: 0, to: -10)
        #expect(table.sum(from: 0, through: 1) == -11)
        #expect(table.sum(from: 4, through: 4) == 5)
    }

    @Test("A single value")
    func single() {
        var table = EditableRangeSums.Table([7])
        #expect(table.sum(from: 0, through: 0) == 7)
        table.update(at: 0, to: -3)
        #expect(table.sum(from: 0, through: 0) == -3)
        table.update(at: 0, to: -3)
        #expect(table.sum(from: 0, through: 0) == -3)
    }

    @Test("Ranges at both ends, and editing the same index twice")
    func edges() {
        var table = EditableRangeSums.Table([1, 2, 3, 4, 5, 6])
        #expect(table.sum(from: 0, through: 0) == 1)
        #expect(table.sum(from: 5, through: 5) == 6)
        #expect(table.sum(from: 0, through: 5) == 21)
        table.update(at: 5, to: 100)
        table.update(at: 5, to: 10)
        #expect(table.sum(from: 3, through: 5) == 19)
        table.update(at: 0, to: 0)
        #expect(table.sum(from: 0, through: 2) == 5)
    }

    @Test("Large values don't overflow")
    func largeValues() {
        let big = 1_000_000_000
        var table = EditableRangeSums.Table(Array(repeating: big, count: 1_000))
        #expect(table.sum(from: 0, through: 999) == 1_000 * big)
        table.update(at: 500, to: -big)
        #expect(table.sum(from: 0, through: 999) == 998 * big)
    }

    @Test("Matches plain addition on 300 small random tables")
    func randomSmall() {
        var random = EditableSumsRandom(seed: 60)
        for _ in 0..<300 {
            let count = Int.random(in: 1...12, using: &random)
            var values = (0..<count).map { _ in Int.random(in: -50...50, using: &random) }
            var table = EditableRangeSums.Table(values)
            for _ in 0..<40 {
                if Bool.random(using: &random) {
                    let index = Int.random(in: 0..<count, using: &random)
                    let value = Int.random(in: -50...50, using: &random)
                    values[index] = value
                    table.update(at: index, to: value)
                } else {
                    let a = Int.random(in: 0..<count, using: &random), b = Int.random(in: 0..<count, using: &random)
                    let start = min(a, b), end = max(a, b)
                    #expect(table.sum(from: start, through: end) == values[start...end].reduce(0, +))
                }
            }
        }
    }

    @Test("100,000 values and 100,000 mixed edits and wide sums")
    func large() {
        // Summing each range directly would touch about 5 × 10⁹ values, and patching a prefix-sum array
        // after each edit costs about as much. The reference is a Fenwick tree.
        var random = EditableSumsRandom(seed: 2_026)
        let count = 100_000
        let values = (0..<count).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        var table = EditableRangeSums.Table(values)
        var reference = EditableSumsFenwick(values)
        var mismatches = 0
        for step in 0..<100_000 {
            if step % 2 == 0 {
                let index = Int.random(in: 0..<count, using: &random)
                let value = Int.random(in: -1_000_000_000...1_000_000_000, using: &random)
                table.update(at: index, to: value)
                reference.update(at: index, to: value)
            } else {
                let start = Int.random(in: 0..<1_000, using: &random)
                let end = count - 1 - Int.random(in: 0..<1_000, using: &random)
                if table.sum(from: start, through: end) != reference.sum(from: start, through: end) {
                    mismatches += 1
                }
            }
        }
        #expect(mismatches == 0)
    }
}
