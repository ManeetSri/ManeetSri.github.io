import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ConstantTimeRandomSetTests {
    typealias RandomSet = ConstantTimeRandomSet.RandomSet

    /// A seeded generator (SplitMix64), so every run draws the same "random" numbers.
    private struct SeededGenerator: RandomNumberGenerator {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    @Test("insert, remove and contains report what happened")
    func basics() {
        var set = RandomSet<Int>()
        #expect(set.isEmpty)
        #expect(set.insert(5) == true)
        #expect(set.insert(5) == false)
        #expect(set.insert(9) == true)
        #expect(set.count == 2)
        #expect(set.contains(5))
        #expect(set.remove(5) == true)
        #expect(set.remove(5) == false)
        #expect(!set.contains(5))
        #expect(set.contains(9))
        #expect(set.count == 1)
        #expect(set.remove(9) == true)
        #expect(set.isEmpty)
    }

    @Test("An empty set has no random element")
    func emptyRandom() {
        var generator = SeededGenerator(seed: 1)
        var set = RandomSet<String>()
        #expect(set.randomElement(using: &generator) == nil)
        #expect(set.randomElement() == nil)
        set.insert("only")
        set.remove("only")
        #expect(set.randomElement(using: &generator) == nil)
    }

    @Test("A single element is always the random one")
    func single() {
        var generator = SeededGenerator(seed: 2)
        var set = RandomSet<String>()
        set.insert("swift")
        for _ in 0..<20 {
            #expect(set.randomElement(using: &generator) == "swift")
        }
        #expect(set.randomElement() == "swift")
    }

    @Test("Every element is equally likely")
    func uniform() {
        var generator = SeededGenerator(seed: 3)
        var set = RandomSet<Int>()
        for value in 0..<10 {
            set.insert(value * 11)
        }
        var tally: [Int: Int] = [:]
        for _ in 0..<50_000 {
            if let value = set.randomElement(using: &generator) {
                tally[value, default: 0] += 1
            }
        }
        #expect(tally.keys.sorted() == (0..<10).map { $0 * 11 })
        #expect(tally.values.allSatisfy { (4_000...6_000).contains($0) }, "each of 10 elements should come up about 5,000 times")
    }

    @Test("Still uniform after removing most elements")
    func uniformAfterRemovals() {
        var generator = SeededGenerator(seed: 4)
        var set = RandomSet<Int>()
        for value in 0..<1_000 {
            set.insert(value)
        }
        for value in 0..<1_000 where value % 100 != 0 {
            set.remove(value)
        }
        #expect(set.count == 10)
        var tally: [Int: Int] = [:]
        for _ in 0..<50_000 {
            if let value = set.randomElement(using: &generator) {
                tally[value, default: 0] += 1
            }
        }
        #expect(tally.keys.sorted() == Array(stride(from: 0, to: 1_000, by: 100)))
        #expect(tally.values.allSatisfy { (4_000...6_000).contains($0) })
    }

    @Test("Thousands of mixed calls match Set", arguments: [1, 2, 3])
    func matchesModel(seed: Int) {
        var generator = SeededGenerator(seed: UInt64(seed))
        var set = RandomSet<Int>()
        var model = Set<Int>()
        for step in 0..<20_000 {
            let value = Int.random(in: 0..<60, using: &generator)
            switch Int.random(in: 0..<4, using: &generator) {
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
                let drawn = set.randomElement(using: &generator)
                if model.isEmpty ? drawn != nil : !(drawn.map { model.contains($0) } ?? false) {
                    Issue.record("randomElement returned \(String(describing: drawn)), not an element, at step \(step)")
                    return
                }
            }
            if set.count != model.count || set.contains(value) != model.contains(value) {
                Issue.record("count or contains is wrong at step \(step)")
                return
            }
        }
    }

    @Test("200,000 random picks from 100,000 elements stay fast", .timeLimit(.minutes(1)))
    func large() {
        var generator = SeededGenerator(seed: 5)
        var set = RandomSet<Int>()
        for value in 0..<200_000 {
            set.insert(value)
        }
        for value in stride(from: 0, to: 200_000, by: 2) {
            set.remove(value)
        }
        #expect(set.count == 100_000)
        var allOdd = true
        var sum = 0
        for _ in 0..<200_000 {
            guard let value = set.randomElement(using: &generator) else {
                allOdd = false
                break
            }
            if value % 2 == 0 { allOdd = false }
            sum += value
        }
        #expect(allOdd)
        #expect((80_000 * 200_000...120_000 * 200_000).contains(sum), "the average pick should be near the middle")
    }
}
