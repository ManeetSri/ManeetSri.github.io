import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A value whose lifetime the tests can watch.
private final class Thumbnail {
    let name: String
    init(_ name: String) { self.name = name }
}

@Suite struct LRUCacheTests {
    @Test("Throws out the least recently used entry")
    func evictsLeastRecent() {
        let cache = LRUCache.Cache<Int, String>(capacity: 2)
        cache.setValue("one", for: 1)
        cache.setValue("two", for: 2)
        #expect(cache.value(for: 1) == "one")    // 1 is now the most recent
        cache.setValue("three", for: 3)           // evicts 2
        #expect(cache.value(for: 2) == nil)
        cache.setValue("four", for: 4)            // evicts 1
        #expect(cache.value(for: 1) == nil)
        #expect(cache.value(for: 3) == "three")
        #expect(cache.value(for: 4) == "four")
        #expect(cache.count == 2)
    }

    @Test("Setting an existing key replaces its value and counts as a use")
    func update() {
        let cache = LRUCache.Cache<String, Int>(capacity: 2)
        cache.setValue(1, for: "a")
        cache.setValue(2, for: "b")
        cache.setValue(10, for: "a")              // a is the most recent again, nothing evicted
        #expect(cache.count == 2)
        cache.setValue(3, for: "c")               // evicts b
        #expect(cache.value(for: "a") == 10)
        #expect(cache.value(for: "b") == nil)
        #expect(cache.value(for: "c") == 3)
    }

    @Test("keysByRecency lists the most recent first")
    func recency() {
        let cache = LRUCache.Cache<Int, Int>(capacity: 3)
        #expect(cache.keysByRecency == [])
        cache.setValue(10, for: 1)
        cache.setValue(20, for: 2)
        cache.setValue(30, for: 3)
        #expect(cache.keysByRecency == [3, 2, 1])
        _ = cache.value(for: 1)
        #expect(cache.keysByRecency == [1, 3, 2])
        _ = cache.value(for: 1)
        #expect(cache.keysByRecency == [1, 3, 2])
        _ = cache.value(for: 99)
        #expect(cache.keysByRecency == [1, 3, 2], "a miss doesn't change the order")
        cache.setValue(25, for: 2)
        #expect(cache.keysByRecency == [2, 1, 3])
        cache.setValue(40, for: 4)
        #expect(cache.keysByRecency == [4, 2, 1])
    }

    @Test("A cache of one keeps only the latest key")
    func capacityOne() {
        let cache = LRUCache.Cache<Int, Int>(capacity: 1)
        cache.setValue(1, for: 1)
        cache.setValue(2, for: 2)
        #expect(cache.value(for: 1) == nil)
        #expect(cache.value(for: 2) == 2)
        cache.setValue(3, for: 2)
        #expect(cache.value(for: 2) == 3)
        #expect(cache.count == 1)
        #expect(cache.keysByRecency == [2])
    }

    @Test("removeValue takes a key out from anywhere in the order")
    func remove() {
        let cache = LRUCache.Cache<Int, Int>(capacity: 4)
        for key in 1...4 {
            cache.setValue(key * 10, for: key)
        }
        #expect(cache.removeValue(for: 3) == 30)    // middle
        #expect(cache.removeValue(for: 4) == 40)    // most recent
        #expect(cache.removeValue(for: 1) == 10)    // least recent
        #expect(cache.removeValue(for: 1) == nil)
        #expect(cache.keysByRecency == [2])
        #expect(cache.count == 1)
        #expect(cache.removeValue(for: 2) == 20)
        #expect(cache.keysByRecency == [])
        cache.setValue(50, for: 5)
        cache.setValue(60, for: 6)
        #expect(cache.keysByRecency == [6, 5])
    }

    @Test("Matches a simple array-based model through thousands of operations", arguments: [1, 2, 3, 5, 8])
    func matchesModel(capacity: Int) {
        let cache = LRUCache.Cache<Int, Int>(capacity: capacity)
        var order: [Int] = []          // most recent first
        var values: [Int: Int] = [:]
        var seed = capacity
        for step in 0..<3_000 {
            seed = (seed * 1_103 + 12_345) % 65_536
            let key = seed % 12
            switch seed % 4 {
            case 0, 1:
                cache.setValue(step, for: key)
                values[key] = step
                order.removeAll { $0 == key }
                order.insert(key, at: 0)
                if order.count > capacity {
                    values[order.removeLast()] = nil
                }
            case 2:
                let expected = values[key]
                if expected != nil {
                    order.removeAll { $0 == key }
                    order.insert(key, at: 0)
                }
                if cache.value(for: key) != expected {
                    Issue.record("value(for: \(key)) is wrong at step \(step)")
                    return
                }
            default:
                let expected = values.removeValue(forKey: key)
                order.removeAll { $0 == key }
                if cache.removeValue(for: key) != expected {
                    Issue.record("removeValue(for: \(key)) is wrong at step \(step)")
                    return
                }
            }
            if cache.keysByRecency != order {
                Issue.record("the order of use is wrong at step \(step)")
                return
            }
        }
        #expect(cache.count == order.count)
    }

    @Test("Doesn't keep values alive after eviction or after the cache is gone")
    func freesValues() {
        weak var evicted: Thumbnail?
        weak var kept: Thumbnail?
        do {
            let cache = LRUCache.Cache<String, Thumbnail>(capacity: 2)
            do {
                let first = Thumbnail("first")
                let second = Thumbnail("second")
                evicted = first
                kept = second
                cache.setValue(first, for: "first")
                cache.setValue(second, for: "second")
            }
            _ = cache.value(for: "first")
            _ = cache.value(for: "second")
            cache.setValue(Thumbnail("third"), for: "third")
            #expect(evicted == nil, "an evicted value should be freed")
            #expect(kept?.name == "second")
        }
        #expect(kept == nil, "freeing the cache should free every node; check for a retain cycle")
    }

    @Test("Every operation stays O(1) with 50,000 entries")
    func large() {
        let cache = LRUCache.Cache<Int, Int>(capacity: 50_000)
        for key in 0..<100_000 {
            cache.setValue(key * 2, for: key)
        }
        #expect(cache.count == 50_000)
        #expect(cache.value(for: 49_999) == nil)
        #expect(cache.value(for: 50_000) == 100_000)
        for key in stride(from: 99_999, through: 50_001, by: -1) {
            _ = cache.value(for: key)             // 50,000 is now the least recently used
        }
        cache.setValue(-1, for: -1)
        #expect(cache.value(for: 50_000) == nil)
        #expect(cache.value(for: 50_001) == 100_002)
        #expect(cache.keysByRecency.prefix(2) == [50_001, -1])
    }
}
