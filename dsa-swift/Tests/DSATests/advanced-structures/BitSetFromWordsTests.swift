import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BitsRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BitSetFromWordsTests {
    private func bits(_ capacity: Int, _ members: [Int]) -> BitSetFromWords.Bits {
        var result = BitSetFromWords.Bits(capacity: capacity)
        members.forEach { result.insert($0) }
        return result
    }

    @Test("Number x lives at bit x % 64 of word x / 64")
    func layout() {
        let set = bits(200, [0, 5, 63, 64, 130, 199])
        #expect(set.words.count == 4)
        #expect(set.words == [1 | 1 << 5 | 1 << 63, 1, 1 << 2, 1 << 7])
        #expect(BitSetFromWords.Bits(capacity: 64).words.count == 1)
        #expect(BitSetFromWords.Bits(capacity: 65).words.count == 2)
        #expect(BitSetFromWords.Bits(capacity: 0).words.isEmpty)
    }

    @Test("Insert, remove, contains, count and elements")
    func basics() {
        var set = bits(100, [42, 7, 99, 7])
        #expect(set.count == 3)
        #expect(set.elements == [7, 42, 99])
        #expect(set.contains(42))
        #expect(!set.contains(43))
        #expect(!set.contains(-1))
        #expect(!set.contains(100))
        set.remove(42)
        set.remove(42)
        set.remove(0)
        #expect(set.elements == [7, 99])
        #expect(set == bits(100, [99, 7]))
    }

    @Test("next(atOrAfter:) finds the next member, across words")
    func nextMember() {
        let set = bits(300, [3, 64, 65, 200, 299])
        #expect(set.next(atOrAfter: 0) == 3)
        #expect(set.next(atOrAfter: 3) == 3)
        #expect(set.next(atOrAfter: 4) == 64)
        #expect(set.next(atOrAfter: 66) == 200)
        #expect(set.next(atOrAfter: 201) == 299)
        #expect(set.next(atOrAfter: 300) == nil)
        #expect(set.next(atOrAfter: 1_000) == nil)
        #expect(set.next(atOrAfter: -5) == 3)
        #expect(bits(300, []).next(atOrAfter: 0) == nil)
    }

    @Test("Union, intersection and difference in place")
    func setOperations() {
        let a = bits(150, [1, 64, 70, 128, 149])
        let b = bits(150, [1, 2, 70, 100, 149])
        var union = a
        union.formUnion(b)
        #expect(union.elements == [1, 2, 64, 70, 100, 128, 149])
        var both = a
        both.formIntersection(b)
        #expect(both.elements == [1, 70, 149])
        var onlyA = a
        onlyA.subtract(b)
        #expect(onlyA.elements == [64, 128])
        #expect(a.elements == [1, 64, 70, 128, 149], "a is a value: copies don't change it")
    }

    @Test("Shifting up moves members across words and drops those past the end", arguments: [
        (200, [0, 60, 130], 10, [10, 70, 140]),
        (200, [60, 130], 70, [130]),
        (200, [0, 1, 63], 64, [64, 65, 127]),
        (200, [0, 1, 63], 128, [128, 129, 191]),
        (200, [5], 0, [5]),
        (200, [0, 199], 1, [1]),
        (200, [0, 50], 199, [199]),
        (200, [0, 50], 500, []),
        (64, [0, 31, 63], 33, [33]),
    ] as [(Int, [Int], Int, [Int])])
    func shifts(capacity: Int, members: [Int], shift: Int, expected: [Int]) {
        let shifted = bits(capacity, members).shiftedUp(by: shift)
        #expect(shifted.elements == expected)
        #expect(shifted.count == expected.count, "no stray bits past capacity")
    }

    @Test("Matches Set<Int> through random operations", arguments: [1, 2, 3] as [UInt64])
    func matchesModel(seed: UInt64) {
        var random = BitsRandom(seed: seed)
        let capacity = [70, 128, 333][Int(seed - 1)]
        var set = BitSetFromWords.Bits(capacity: capacity)
        var model = Set<Int>()
        for step in 0..<3_000 {
            let x = Int.random(in: 0..<capacity, using: &random)
            switch Int.random(in: 0..<8, using: &random) {
            case 0, 1, 2:
                set.insert(x)
                model.insert(x)
            case 3:
                set.remove(x)
                model.remove(x)
            case 4:
                let other = (0..<10).map { _ in Int.random(in: 0..<capacity, using: &random) }
                set.formUnion(bits(capacity, other))
                model.formUnion(other)
            case 5:
                let keep = (0..<capacity / 2).map { _ in Int.random(in: 0..<capacity, using: &random) }
                set.formIntersection(bits(capacity, keep))
                model.formIntersection(keep)
            case 6:
                let s = Int.random(in: 0...(capacity + 10), using: &random)
                set = set.shiftedUp(by: s)
                model = Set(model.map { $0 + s }.filter { $0 < capacity })
            default:
                let expected = model.filter { $0 >= x }.min()
                if set.next(atOrAfter: x) != expected {
                    Issue.record("next(atOrAfter: \(x)) is wrong at step \(step)")
                    return
                }
            }
            if set.elements != model.sorted() || set.count != model.count || set.contains(x) != model.contains(x) {
                Issue.record("the members are wrong at step \(step)")
                return
            }
        }
    }

    @Test("Reachable subset sums", arguments: [
        ([3, 5, 7, 11], 30, [0, 3, 5, 7, 8, 10, 11, 12, 14, 15, 16, 18, 19, 21, 23, 26]),
        ([], 5, [0]),
        ([2, 2, 2], 10, [0, 2, 4, 6]),
        ([10, 1], 5, [0, 1]),
        ([64, 1], 65, [0, 1, 64, 65]),
        ([4], 0, [0]),
    ] as [([Int], Int, [Int])])
    func sums(weights: [Int], limit: Int, expected: [Int]) {
        #expect(BitSetFromWords.reachableSums(weights: weights, limit: limit) == expected)
    }

    @Test("Subset sums match a simple DP on random inputs")
    func sumsMatchDP() {
        var random = BitsRandom(seed: 9)
        for _ in 0..<20 {
            let weights = (0..<Int.random(in: 1...40, using: &random)).map { _ in Int.random(in: 1...300, using: &random) }
            let limit = Int.random(in: 0...3_000, using: &random)
            var canMake = Array(repeating: false, count: limit + 1)
            canMake[0] = true
            for w in weights where w <= limit {
                for total in stride(from: limit, through: w, by: -1) where canMake[total - w] {
                    canMake[total] = true
                }
            }
            let expected = canMake.indices.filter { canMake[$0] }
            #expect(BitSetFromWords.reachableSums(weights: weights, limit: limit) == expected)
        }
    }

    @Test("Large: a million-number set, and subset sums of 2,000 weights up to 100,000")
    func large() {
        var threes = BitSetFromWords.Bits(capacity: 1_000_000)
        var fives = BitSetFromWords.Bits(capacity: 1_000_000)
        for x in stride(from: 0, to: 1_000_000, by: 3) { threes.insert(x) }
        for x in stride(from: 0, to: 1_000_000, by: 5) { fives.insert(x) }
        var both = threes
        both.formIntersection(fives)
        #expect(both.count == 66_667)
        #expect(both.next(atOrAfter: 999_990) == 999_990)
        #expect(both.next(atOrAfter: 999_991) == nil)
        threes.formUnion(fives)
        #expect(threes.count == 466_667)

        // 1,000 copies each of 97 and 89: the reachable totals are exactly 97a + 89b
        let weights = Array(repeating: 97, count: 1_000) + Array(repeating: 89, count: 1_000)
        let limit = 100_000
        var expected = Set<Int>()
        for a in 0...1_000 {
            for b in 0...1_000 where 97 * a + 89 * b <= limit {
                expected.insert(97 * a + 89 * b)
            }
        }
        #expect(BitSetFromWords.reachableSums(weights: weights, limit: limit) == expected.sorted())
    }
}
