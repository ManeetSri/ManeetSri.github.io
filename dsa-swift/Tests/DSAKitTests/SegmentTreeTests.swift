import Testing
import DSAKit

@Suite struct SegmentTreeTests {
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

    @Test("Range sums, with half-open, closed and one-sided ranges")
    func sums() {
        let tree = SegmentTree([5, 3, 7, 9, 6, 4, 1, 2], identity: 0, merge: +)
        #expect(tree.count == 8)
        #expect(tree.query(2..<7) == 27)
        #expect(tree.query(2...6) == 27)
        #expect(tree.query(..<3) == 15)
        #expect(tree.query(5...) == 7)
        #expect(tree.query(...) == 37)
        #expect(tree.query(0...0) == 5)
        #expect(tree.query(7...7) == 2)
        #expect(SegmentTree.sum([1.5, 2.25]).query(...) == 3.75)
    }

    @Test("Minimums and maximums")
    func minAndMax() {
        let values = [4, -2, 8, 0, 8, -7, 3]
        let lowest = SegmentTree.minimum(values)
        let highest = SegmentTree.maximum(values)
        #expect(lowest.query(...) == -7)
        #expect(lowest.query(0..<3) == -2)
        #expect(lowest.query(2...3) == 0)
        #expect(highest.query(...) == 8)
        #expect(highest.query(3...) == 8)
        #expect(highest.query(5...6) == 3)
        let custom = SegmentTree(values, identity: Int.min, merge: max)
        #expect(custom.query(0...1) == 4)
    }

    @Test("Empty ranges give the identity")
    func emptyRanges() {
        let tree = SegmentTree.sum([1, 2, 3])
        #expect(tree.query(0..<0) == 0)
        #expect(tree.query(3..<3) == 0)
        #expect(tree.query(1..<1) == 0)
        #expect(SegmentTree.minimum([5, 1]).query(2...) == Int.max)
        #expect(SegmentTree.maximum([5, 1]).query(..<0) == Int.min)
    }

    @Test("An empty tree and a single element")
    func emptyAndSingle() {
        let empty = SegmentTree<Int>([], identity: 0, merge: +)
        #expect(empty.isEmpty)
        #expect(empty.count == 0)
        #expect(empty.query(...) == 0)
        #expect(Array(empty) == [])

        var single = SegmentTree.sum([42])
        #expect(single.query(...) == 42)
        #expect(single[0] == 42)
        single.update(at: 0, to: -1)
        #expect(single.query(0...0) == -1)
        #expect(single.query(0..<0) == 0)
    }

    @Test("Updates change only what they should")
    func updates() {
        var tree = SegmentTree.sum([5, 3, 7, 9, 6, 4, 1, 2])
        tree.update(at: 3, to: 1)
        #expect(tree.query(2...6) == 19)
        #expect(tree[3] == 1)
        #expect(tree.values == [5, 3, 7, 1, 6, 4, 1, 2])
        tree.update(at: 0, with: { $0 * 10 })
        #expect(tree.query(0...1) == 53)
        tree.update(at: 7, with: { $0 - 2 })
        #expect(tree.query(...) == 72)
        #expect(Array(tree) == [50, 3, 7, 1, 6, 4, 1, 0])
        #expect(tree.description == "SegmentTree([50, 3, 7, 1, 6, 4, 1, 0])")
    }

    @Test("A merge that isn't commutative keeps left-to-right order", arguments: [1, 2, 3, 5, 6, 7, 10, 13, 16, 31])
    func nonCommutative(count: Int) {
        let letters = (0..<count).map { String(UnicodeScalar(UInt8(97 + $0 % 26))) }
        var tree = SegmentTree(letters, identity: "", merge: +)
        var model = letters
        for low in 0...count {
            for high in low...count {
                #expect(tree.query(low..<high) == model[low..<high].joined())
            }
        }
        tree.update(at: count / 2, to: "Z")
        model[count / 2] = "Z"
        for low in 0...count {
            for high in low...count {
                #expect(tree.query(low..<high) == model[low..<high].joined())
            }
        }
    }

    @Test("A tuple monoid: the smallest value and where it is")
    func smallestWithPosition() {
        let prices = [7, 3, 9, 3, 5]
        typealias Best = (value: Int, index: Int)
        let tree = SegmentTree<Best>(
            prices.enumerated().map { ($0.element, $0.offset) },
            identity: (Int.max, Int.max),
            merge: { $0.value != $1.value ? ($0.value < $1.value ? $0 : $1) : ($0.index < $1.index ? $0 : $1) }
        )
        #expect(tree.query(...).index == 1)
        #expect(tree.query(2...).index == 3)
        #expect(tree.query(2...2).value == 9)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        let original = SegmentTree.sum([1, 2, 3])
        var copy = original
        copy.update(at: 1, to: 20)
        #expect(original.query(...) == 6)
        #expect(copy.query(...) == 24)
    }

    @Test("Thousands of random updates and queries agree with a plain array", arguments: [1, 2, 7, 64, 100, 1_000])
    func randomAgainstArray(count: Int) {
        var steps = Steps(seed: UInt64(count))
        var model = (0..<count).map { _ in steps.next(below: 2_001) - 1_000 }
        var sums = SegmentTree.sum(model)
        var lowest = SegmentTree.minimum(model)
        var highest = SegmentTree.maximum(model)
        var mismatches = 0
        for _ in 0..<5_000 {
            if steps.next(below: 2) == 0 {
                let index = steps.next(below: count)
                let value = steps.next(below: 2_001) - 1_000
                model[index] = value
                sums.update(at: index, to: value)
                lowest.update(at: index, to: value)
                highest.update(at: index, to: value)
            } else {
                let a = steps.next(below: count + 1)
                let b = steps.next(below: count + 1)
                let range = min(a, b)..<max(a, b)
                let slice = model[range]
                if sums.query(range) != slice.reduce(0, +) { mismatches += 1 }
                if lowest.query(range) != (slice.min() ?? Int.max) { mismatches += 1 }
                if highest.query(range) != (slice.max() ?? Int.min) { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
        #expect(sums.values == model)
    }

    @Test("100,000 values: build, then 100,000 operations")
    func large() {
        let count = 100_000
        var tree = SegmentTree.sum(Array(1...count))
        #expect(tree.query(...) == count * (count + 1) / 2)
        for index in stride(from: 0, to: count, by: 2) {
            tree.update(at: index, to: 0)              // keep only the even numbers 2, 4, 6, ...
        }
        #expect(tree.query(...) == 2 * (count / 2) * (count / 2 + 1) / 2)
        var total = 0
        for start in 0..<50_000 {
            total &+= tree.query(start..<(start + 50_000))
        }
        #expect(total > 0)
    }
}

@Suite struct LazySegmentTreeTests {
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

    @Test("Range additions, then sums, minimums and maximums")
    func basics() {
        var days = LazySegmentTree([4, 0, 2, 5])
        days.add(3, to: 1...2)
        #expect(days.values == [4, 3, 5, 5])
        #expect(days.sum(in: 0..<3) == 12)
        #expect(days.minimum(in: 1...3) == 3)
        #expect(days.maximum(in: ...) == 5)
        days.add(-10, to: ...)
        #expect(days.values == [-6, -7, -5, -5])
        #expect(days.sum(in: 2...) == -10)
        #expect(days.value(at: 1) == -7)
        #expect(days.description == "LazySegmentTree([-6, -7, -5, -5])")
    }

    @Test("Empty ranges, an empty tree and a single element")
    func edges() {
        var tree = LazySegmentTree(count: 3)
        tree.add(5, to: 1..<1)
        #expect(tree.values == [0, 0, 0])
        #expect(tree.sum(in: 2..<2) == 0)
        #expect(tree.minimum(in: 0..<0) == Int.max)
        #expect(tree.maximum(in: 3...) == Int.min)

        var empty = LazySegmentTree([])
        #expect(empty.isEmpty)
        empty.add(1, to: ...)
        #expect(empty.sum(in: ...) == 0)
        #expect(empty.values == [])

        var single = LazySegmentTree([7])
        single.add(2, to: 0...0)
        single.add(1, to: ...)
        #expect(single.sum(in: ...) == 10)
        #expect(single.minimum(in: ...) == 10)
    }

    @Test("Overlapping additions stack up", arguments: [1, 2, 5, 8, 13, 100])
    func overlapping(count: Int) {
        var tree = LazySegmentTree(count: count)
        var model = Array(repeating: 0, count: count)
        for low in 0..<count {
            tree.add(low + 1, to: low...)
            for index in low..<count { model[index] += low + 1 }
        }
        #expect(tree.values == model)
        #expect(tree.sum(in: ...) == model.reduce(0, +))
    }

    @Test("Thousands of random operations agree with a plain array", arguments: [1, 3, 16, 50, 777])
    func randomAgainstArray(count: Int) {
        var steps = Steps(seed: UInt64(count * 31))
        var model = (0..<count).map { _ in steps.next(below: 201) - 100 }
        var tree = LazySegmentTree(model)
        var mismatches = 0
        for _ in 0..<5_000 {
            let a = steps.next(below: count + 1)
            let b = steps.next(below: count + 1)
            let range = min(a, b)..<max(a, b)
            switch steps.next(below: 4) {
            case 0, 1:
                let delta = steps.next(below: 201) - 100
                tree.add(delta, to: range)
                for index in range { model[index] += delta }
            case 2:
                if tree.sum(in: range) != model[range].reduce(0, +) { mismatches += 1 }
            default:
                if tree.minimum(in: range) != (model[range].min() ?? Int.max) { mismatches += 1 }
                if tree.maximum(in: range) != (model[range].max() ?? Int.min) { mismatches += 1 }
            }
        }
        #expect(mismatches == 0)
        #expect(tree.values == model)
    }

    @Test("100,000 range additions and sums")
    func large() {
        let count = 100_000
        var tree = LazySegmentTree(count: count)
        for start in 0..<50_000 {
            tree.add(1, to: start..<(start + 50_000))
        }
        // Position p is covered by every start in max(0, p - 49,999)...min(p, 49,999)
        #expect(tree.value(at: 0) == 1)
        #expect(tree.value(at: 49_999) == 50_000)
        #expect(tree.value(at: 99_998) == 1)
        #expect(tree.value(at: 99_999) == 0)
        #expect(tree.sum(in: ...) == 50_000 * 50_000)
        #expect(tree.maximum(in: ...) == 50_000)
    }
}
