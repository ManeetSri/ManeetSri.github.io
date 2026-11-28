import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct VersionedKeyValueStoreTests {
    typealias Store = VersionedKeyValueStore.Store

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("Answers with the value at the latest time at or before the question")
    func example() {
        var settings = Store<String, String>()
        settings.set("light", for: "theme", at: 10)
        settings.set("dark", for: "theme", at: 20)
        #expect(settings.value(for: "theme", at: 5) == nil)
        #expect(settings.value(for: "theme", at: 10) == "light")
        #expect(settings.value(for: "theme", at: 15) == "light")
        #expect(settings.value(for: "theme", at: 20) == "dark")
        #expect(settings.value(for: "theme", at: 1_000) == "dark")
        #expect(settings.value(for: "font", at: 15) == nil)
    }

    @Test("Each key keeps its own history")
    func separateKeys() {
        var prices = Store<String, Int>()
        prices.set(100, for: "apple", at: 1)
        prices.set(250, for: "pear", at: 2)
        prices.set(110, for: "apple", at: 3)
        prices.set(240, for: "pear", at: 7)
        #expect(prices.value(for: "apple", at: 2) == 100)
        #expect(prices.value(for: "pear", at: 2) == 250)
        #expect(prices.value(for: "apple", at: 6) == 110)
        #expect(prices.value(for: "pear", at: 6) == 250)
        #expect(prices.value(for: "pear", at: 7) == 240)
        #expect(prices.value(for: "pear", at: 1) == nil)
    }

    @Test("Asking about the past never changes the answer")
    func pastIsStable() {
        var store = Store<Int, Int>()
        for time in 1...50 {
            store.set(time * time, for: 0, at: time * 2)
        }
        for time in 1...50 {
            #expect(store.value(for: 0, at: time * 2) == time * time)
            #expect(store.value(for: 0, at: time * 2 + 1) == time * time)
        }
        #expect(store.value(for: 0, at: 1) == nil)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = Store<String, Int>()
        original.set(1, for: "a", at: 1)
        var copy = original
        copy.set(2, for: "a", at: 2)
        #expect(original.value(for: "a", at: 5) == 1)
        #expect(copy.value(for: "a", at: 5) == 2)
    }

    @Test("Thousands of mixed calls match a simple model", arguments: [1, 2, 3])
    func matchesModel(seed: Int) {
        var steps = Steps(seed: UInt64(seed) &* 7_919)
        var store = Store<Int, String>()
        var history: [Int: [(time: Int, value: String)]] = [:]
        var time = 0
        for step in 0..<5_000 {
            let key = steps.next(below: 8)
            if steps.next(below: 3) == 0 {
                time += 1 + steps.next(below: 3)
                let value = "v\(step)"
                store.set(value, for: key, at: time)
                history[key, default: []].append((time, value))
            } else {
                let asked = steps.next(below: time + 6)
                let expected = history[key]?.last { $0.time <= asked }?.value
                if store.value(for: key, at: asked) != expected {
                    Issue.record("value(for: \(key), at: \(asked)) is wrong at step \(step)")
                    return
                }
            }
        }
    }

    @Test("Binary search keeps 200,000 questions fast with 20,000 versions per key", .timeLimit(.minutes(1)))
    func large() {
        var steps = Steps(seed: 4)
        var store = Store<Int, Int>()
        for time in 1...100_000 {
            store.set(time * 10, for: time % 5, at: time)        // key k is set at times ≡ k (mod 5)
        }
        var correct = true
        for _ in 0..<200_000 {
            let key = steps.next(below: 5)
            let asked = steps.next(below: 110_000)
            let latest = min(asked, 100_000)
            let time = latest - ((latest - key) % 5 + 5) % 5    // the last time ≤ latest with time ≡ key
            let expected = time >= 1 ? time * 10 : nil
            if store.value(for: key, at: asked) != expected {
                correct = false
                break
            }
        }
        #expect(correct)
    }
}
