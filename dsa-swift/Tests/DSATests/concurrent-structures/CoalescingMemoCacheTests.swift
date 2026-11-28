import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// Records how many times each key was computed. An actor, so concurrent computations can share it.
private actor MemoCallLog {
    private var calls: [Int: Int] = [:]

    func record(_ key: Int) {
        calls[key, default: 0] += 1
    }

    func count(for key: Int) -> Int {
        calls[key, default: 0]
    }

    var total: Int {
        calls.values.reduce(0, +)
    }
}

@Suite struct CoalescingMemoCacheTests {
    /// A slow-ish square: it records the call, then suspends a few times so other requests can arrive
    /// while it's still running
    private func square(_ log: MemoCallLog) -> @Sendable (Int) async -> Int {
        { key in
            await log.record(key)
            for _ in 0..<5 {
                await Task.yield()
            }
            return key * key
        }
    }

    @Test("Sequential requests compute once and then hit the cache")
    func sequential() async {
        let log = MemoCallLog()
        let cache = CoalescingMemoCache.Store<Int, Int>()
        #expect(await cache.value(for: 7, compute: square(log)) == 49)
        #expect(await cache.value(for: 7, compute: square(log)) == 49)
        #expect(await cache.value(for: 3, compute: square(log)) == 9)
        #expect(await log.count(for: 7) == 1)
        #expect(await log.count(for: 3) == 1)
        #expect(await cache.storedCount == 2)
    }

    @Test("Fifty concurrent requests for one key compute it once")
    func concurrentSameKey() async {
        let log = MemoCallLog()
        let cache = CoalescingMemoCache.Store<Int, Int>()
        let compute = square(log)
        // Five rounds, each with a new key, so a cache that only sometimes coalesces is caught
        for key in 12...16 {
            let results = await withTaskGroup(of: Int.self) { group in
                for _ in 0..<50 {
                    group.addTask { await cache.value(for: key, compute: compute) }
                }
                var all: [Int] = []
                for await result in group {
                    all.append(result)
                }
                return all
            }
            #expect(results.count == 50)
            #expect(results.allSatisfy { $0 == key * key })
            #expect(await log.count(for: key) == 1)
        }
        #expect(await cache.storedCount == 5)
    }

    @Test("Ten keys, each requested five times at once, compute ten times")
    func concurrentManyKeys() async {
        let log = MemoCallLog()
        let cache = CoalescingMemoCache.Store<Int, Int>()
        let compute = square(log)
        let sum = await withTaskGroup(of: Int.self) { group in
            for round in 0..<5 {
                for key in 0..<10 {
                    group.addTask { await cache.value(for: (key + round) % 10, compute: compute) }
                }
            }
            var total = 0
            for await result in group {
                total += result
            }
            return total
        }
        #expect(sum == 5 * (0..<10).map { $0 * $0 }.reduce(0, +))
        #expect(await log.total == 10)
        #expect(await cache.storedCount == 10)
    }

    @Test("forget makes the next request compute again")
    func forget() async {
        let log = MemoCallLog()
        let cache = CoalescingMemoCache.Store<Int, Int>()
        #expect(await cache.value(for: 5, compute: square(log)) == 25)
        await cache.forget(5)
        #expect(await cache.storedCount == 0)
        await cache.forget(99)
        #expect(await cache.value(for: 5, compute: square(log)) == 25)
        #expect(await cache.value(for: 5, compute: square(log)) == 25)
        #expect(await log.count(for: 5) == 2)
        #expect(await cache.storedCount == 1)
    }

    @Test("Any Hashable, Sendable key and Sendable value")
    func strings() async {
        let cache = CoalescingMemoCache.Store<String, [Character]>()
        let reversed: @Sendable (String) async -> [Character] = { Array($0.reversed()) }
        #expect(await cache.value(for: "swift", compute: reversed) == ["t", "f", "i", "w", "s"])
        // The stored value wins over a different closure for the same key
        #expect(await cache.value(for: "swift", compute: { _ in [] }) == ["t", "f", "i", "w", "s"])
        #expect(await cache.storedCount == 1)
    }
}
