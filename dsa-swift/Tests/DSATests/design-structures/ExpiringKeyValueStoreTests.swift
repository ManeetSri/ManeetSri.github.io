import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ExpiringKeyValueStoreTests {
    typealias Store = ExpiringKeyValueStore.Store

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    @Test("An entry lives for exactly its time to live")
    func example() {
        var sessions = Store<String, String>()
        sessions.set("token-1", for: "maneet", ttl: 10, now: 0)
        #expect(sessions.value(for: "maneet", now: 9) == "token-1")
        #expect(sessions.count(now: 9) == 1)
        #expect(sessions.value(for: "maneet", now: 10) == nil)
        #expect(sessions.count(now: 10) == 0)
        #expect(sessions.value(for: "nobody", now: 10) == nil)
    }

    @Test("Setting a key again replaces its value and restarts its clock")
    func overwriteRestarts() {
        var store = Store<String, Int>()
        store.set(1, for: "a", ttl: 5, now: 0)
        store.set(2, for: "a", ttl: 5, now: 3)
        #expect(store.value(for: "a", now: 7) == 2)
        #expect(store.count(now: 7) == 1)
        #expect(store.count(now: 8) == 0)
    }

    @Test("A shorter time to live replaces a longer one")
    func overwriteShorter() {
        var store = Store<String, Int>()
        store.set(1, for: "a", ttl: 100, now: 0)
        store.set(2, for: "a", ttl: 1, now: 1)
        #expect(store.count(now: 1) == 1)
        #expect(store.count(now: 2) == 0)
        #expect(store.value(for: "a", now: 50) == nil)
        #expect(store.count(now: 100) == 0)
        store.set(3, for: "a", ttl: 10, now: 100)
        #expect(store.count(now: 105) == 1, "an old deadline mustn't remove a newer entry")
        #expect(store.value(for: "a", now: 109) == 3)
    }

    @Test("removeValue returns the value only while it's live")
    func removing() {
        var store = Store<Int, String>()
        store.set("x", for: 1, ttl: 5, now: 0)
        store.set("y", for: 2, ttl: 5, now: 0)
        #expect(store.removeValue(for: 1, now: 2) == "x")
        #expect(store.removeValue(for: 1, now: 2) == nil)
        #expect(store.count(now: 2) == 1)
        #expect(store.removeValue(for: 2, now: 5) == nil)
        #expect(store.count(now: 5) == 0)
        store.set("z", for: 1, ttl: 3, now: 5)
        #expect(store.count(now: 7) == 1)
    }

    @Test("Many keys expire at different times")
    func staggered() {
        var store = Store<Int, Int>()
        for key in 0..<10 {
            store.set(key, for: key, ttl: key + 1, now: 0)    // key k lives until time k + 1
        }
        for time in 0...11 {
            #expect(store.count(now: time) == max(0, 10 - time))
        }
    }

    @Test("Thousands of mixed calls match a simple model", arguments: [1, 2, 3])
    func matchesModel(seed: Int) {
        var steps = Steps(seed: UInt64(seed) &* 2_017)
        var store = Store<Int, Int>()
        var model: [Int: (value: Int, expiresAt: Int)] = [:]
        var now = 0
        for step in 0..<6_000 {
            now += steps.next(below: 3)
            let key = steps.next(below: 10)
            switch steps.next(below: 5) {
            case 0, 1:
                let ttl = 1 + steps.next(below: 20)
                store.set(step, for: key, ttl: ttl, now: now)
                model[key] = (step, now + ttl)
            case 2:
                let expected = model[key].flatMap { $0.expiresAt > now ? $0.value : nil }
                if store.value(for: key, now: now) != expected {
                    Issue.record("value(for: \(key), now: \(now)) is wrong at step \(step)")
                    return
                }
            case 3:
                let expected = model.removeValue(forKey: key).flatMap { $0.expiresAt > now ? $0.value : nil }
                if store.removeValue(for: key, now: now) != expected {
                    Issue.record("removeValue(for: \(key), now: \(now)) is wrong at step \(step)")
                    return
                }
            default:
                let expected = model.values.filter { $0.expiresAt > now }.count
                if store.count(now: now) != expected {
                    Issue.record("count(now: \(now)) is wrong at step \(step)")
                    return
                }
            }
        }
    }

    @Test("count stays fast with 25,000 live entries", .timeLimit(.minutes(1)))
    func large() {
        var store = Store<Int, Int>()
        let total = 200_000
        var expiringAt = Array(repeating: 0, count: total + 50_001)
        var live = 0
        var correct = true
        for now in 0..<total {
            let ttl = 1 + (now &* 7_919) % 50_000
            store.set(now, for: now, ttl: ttl, now: now)
            expiringAt[now + ttl] += 1
            live += 1 - expiringAt[now]                       // add this one, drop those due now
            if store.count(now: now) != live {
                correct = false
                break
            }
        }
        #expect(correct)
        #expect(store.value(for: total - 1, now: total - 1) == total - 1)
    }

    @Test("Overwriting the same keys 200,000 times")
    func churn() {
        var store = Store<Int, Int>()
        var correct = true
        for now in 0..<200_000 {
            store.set(now, for: now % 100, ttl: 1_000_000, now: now)
            if now % 1_000 == 999 && (store.count(now: now) != 100 || store.value(for: now % 100, now: now) != now) {
                correct = false
            }
        }
        #expect(correct)
        #expect(store.count(now: 1_199_899) == 100)
        #expect(store.count(now: 1_199_900) == 99)
        #expect(store.count(now: 1_200_000) == 0)
    }
}
