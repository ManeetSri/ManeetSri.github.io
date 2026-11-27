import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A seeded coin: the same flips on every run.
private final class SeededCoin {
    private var state: UInt64
    private(set) var flips = 0

    init(seed: UInt64) {
        state = seed
    }

    func flip() -> Bool {
        flips += 1
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return (z ^ (z >> 31)) & 1 == 1
    }
}

/// A coin that plays back a fixed script, then always comes up tails.
private final class ScriptedCoin {
    private var script: [Bool]
    private(set) var flips = 0

    init(_ script: [Bool]) {
        self.script = script.reversed()
    }

    func flip() -> Bool {
        flips += 1
        return script.popLast() ?? false
    }
}

@Suite struct SkipListFromScratchTests {
    @Test("Inserts, finds and removes values")
    func basics() {
        let coin = SeededCoin(seed: 1)
        let set = SkipListFromScratch.SkipSet(coinFlip: coin.flip)
        #expect(set.count == 0)
        #expect(set.elements == [])
        #expect(set.levelSizes == [])
        #expect(!set.contains(5))
        #expect(set.ceiling(5) == nil)
        for value in [30, 10, 50, 20, 40] {
            #expect(set.insert(value))
        }
        #expect(!set.insert(20))
        #expect(set.count == 5)
        #expect(set.elements == [10, 20, 30, 40, 50])
        #expect(set.contains(40))
        #expect(!set.contains(45))
        #expect(set.ceiling(25) == 30)
        #expect(set.ceiling(30) == 30)
        #expect(set.ceiling(51) == nil)
        #expect(set.ceiling(Int.min + 1) == 10)
        #expect(set.remove(30))
        #expect(!set.remove(30))
        #expect(set.elements == [10, 20, 40, 50])
        #expect(set.count == 4)
    }

    @Test("Negative numbers and the extremes of Int")
    func extremes() {
        let coin = SeededCoin(seed: 2)
        let set = SkipListFromScratch.SkipSet(coinFlip: coin.flip)
        for value in [0, -5, Int.max, Int.min, 7, -100] {
            set.insert(value)
        }
        #expect(set.elements == [Int.min, -100, -5, 0, 7, Int.max])
        #expect(set.contains(Int.min))
        #expect(set.contains(Int.max))
        #expect(set.ceiling(8) == Int.max)
        #expect(set.remove(Int.min))
        #expect(set.elements.first == -100)
    }

    @Test("Heights follow the coin: one level per heads, stopping at the first tails")
    func scriptedHeights() {
        // Heights 1, 3, 2, 1, 4: the script is the flips for each insert in turn
        let coin = ScriptedCoin([false, true, true, false, true, false, false, true, true, true, false])
        let set = SkipListFromScratch.SkipSet(coinFlip: coin.flip)
        for value in [5, 1, 4, 2, 3] {
            set.insert(value)
        }
        #expect(coin.flips == 11)
        #expect(set.levelSizes == [5, 3, 2, 1])
        #expect(set.elements == [1, 2, 3, 4, 5])
        set.remove(3)                               // the only node on level 4
        #expect(set.levelSizes == [4, 2, 1])
        set.remove(1)                               // the only node left on level 3
        #expect(set.levelSizes == [3, 1])
        #expect(set.elements == [2, 4, 5])
    }

    @Test("A value that's already present doesn't use the coin")
    func duplicatesDontFlip() {
        let coin = SeededCoin(seed: 3)
        let set = SkipListFromScratch.SkipSet(coinFlip: coin.flip)
        set.insert(1)
        set.insert(2)
        let before = coin.flips
        #expect(!set.insert(1))
        #expect(!set.insert(2))
        #expect(coin.flips == before)
    }

    @Test("maxLevel caps the height", arguments: [1, 2, 4])
    func maxLevelCap(maxLevel: Int) {
        var flips = 0
        let set = SkipListFromScratch.SkipSet(maxLevel: maxLevel) {
            flips += 1
            return true                             // always heads
        }
        for value in 1...6 {
            set.insert(value)
        }
        #expect(flips == 6 * (maxLevel - 1))
        #expect(set.levelSizes == Array(repeating: 6, count: maxLevel))
    }

    @Test("A coin that always comes up tails gives a plain sorted list")
    func alwaysTails() {
        let set = SkipListFromScratch.SkipSet { false }
        for value in [9, 3, 7, 1] {
            set.insert(value)
        }
        #expect(set.levelSizes == [4])
        #expect(set.elements == [1, 3, 7, 9])
    }

    @Test("Matches a Set through thousands of random operations", arguments: [10, 20, 30] as [UInt64])
    func matchesModel(seed: UInt64) {
        let coin = SeededCoin(seed: seed)
        let set = SkipListFromScratch.SkipSet(coinFlip: coin.flip)
        var model = Set<Int>()
        let random = SeededCoin(seed: seed &* 977)
        func roll(_ limit: Int) -> Int {
            var value = 0
            for _ in 0..<16 { value = value << 1 | (random.flip() ? 1 : 0) }
            return value % limit
        }
        for step in 0..<3_000 {
            let value = roll(200) - 100
            switch roll(4) {
            case 0, 1:
                if set.insert(value) != model.insert(value).inserted {
                    Issue.record("insert(\(value)) returned the wrong answer at step \(step)")
                    return
                }
            case 2:
                if set.remove(value) != (model.remove(value) != nil) {
                    Issue.record("remove(\(value)) returned the wrong answer at step \(step)")
                    return
                }
            default:
                let expected = model.filter { $0 >= value }.min()
                if set.contains(value) != model.contains(value) || set.ceiling(value) != expected {
                    Issue.record("contains or ceiling of \(value) is wrong at step \(step)")
                    return
                }
            }
            if set.count != model.count {
                Issue.record("count is wrong at step \(step)")
                return
            }
        }
        #expect(set.elements == model.sorted())
        let sizes = set.levelSizes
        #expect(sizes.first == model.count)
        #expect(zip(sizes, sizes.dropFirst()).allSatisfy { $0 >= $1 }, "each level holds a subset of the one below")
    }

    @Test("100,000 sorted inserts and lookups stay fast")
    func large() {
        let n = 100_000
        let coin = SeededCoin(seed: 64)
        let set = SkipListFromScratch.SkipSet(maxLevel: 24, coinFlip: coin.flip)
        for value in 0..<n {
            set.insert(value * 2)                   // sorted input: no help from the order
        }
        #expect(set.count == n)
        for value in stride(from: 0, to: 2 * n, by: 7) {
            if set.contains(value) != value.isMultiple(of: 2) {
                Issue.record("contains(\(value)) is wrong")
                return
            }
        }
        #expect(set.ceiling(2 * n - 3) == 2 * n - 2)
        #expect(set.ceiling(2 * n) == nil)
        for value in stride(from: 0, to: 2 * n, by: 4) {
            set.remove(value)
        }
        #expect(set.count == n / 2)
        #expect(set.ceiling(0) == 2)
        let sizes = set.levelSizes
        #expect(sizes.count >= 10 && sizes.count <= 24, "about log₂ n levels")
        let levelTwo = sizes.count > 1 ? sizes[1] : 0
        #expect(levelTwo > n / 8 && levelTwo < n * 3 / 8, "about half the nodes reach level 2")
    }
}
