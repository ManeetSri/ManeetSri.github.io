import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A value whose lifetime the tests can watch.
private final class Tile {
    let name: String
    init(_ name: String) { self.name = name }
}

/// A slow but obvious LFU cache: scan every entry to find the victim.
private struct LFUModel {
    struct Entry {
        let key: Int
        var value: Int
        var frequency: Int
        var lastUse: Int
    }

    let capacity: Int
    var entries: [Entry] = []
    var clock = 0

    mutating func value(for key: Int) -> Int? {
        guard let i = entries.firstIndex(where: { $0.key == key }) else { return nil }
        clock += 1
        entries[i].frequency += 1
        entries[i].lastUse = clock
        return entries[i].value
    }

    mutating func setValue(_ value: Int, for key: Int) {
        guard capacity > 0 else { return }
        clock += 1
        if let i = entries.firstIndex(where: { $0.key == key }) {
            entries[i].value = value
            entries[i].frequency += 1
            entries[i].lastUse = clock
            return
        }
        if entries.count == capacity {
            let victim = entries.indices.min { (entries[$0].frequency, entries[$0].lastUse) < (entries[$1].frequency, entries[$1].lastUse) }!
            entries.remove(at: victim)
        }
        entries.append(Entry(key: key, value: value, frequency: 1, lastUse: clock))
    }

    var evictionOrder: [Int] {
        entries.sorted { ($0.frequency, $0.lastUse) < ($1.frequency, $1.lastUse) }.map(\.key)
    }
}

@Suite struct LFUCacheTests {
    @Test("Evicts the least frequently used key")
    func evictsLeastFrequent() {
        let cache = LFUCache.Cache<String, Int>(capacity: 2)
        cache.setValue(1, for: "a")
        cache.setValue(2, for: "b")
        #expect(cache.value(for: "a") == 1)        // a: 2 uses, b: 1
        cache.setValue(3, for: "c")                 // evicts b
        #expect(cache.value(for: "b") == nil)
        #expect(cache.value(for: "a") == 1)
        #expect(cache.value(for: "c") == 3)
        #expect(cache.count == 2)
    }

    @Test("Ties go to the least recently used key")
    func tieBreak() {
        let cache = LFUCache.Cache<String, Int>(capacity: 2)
        cache.setValue(1, for: "a")
        cache.setValue(2, for: "b")
        _ = cache.value(for: "a")
        cache.setValue(3, for: "c")                 // evicts b; a has 2 uses, c has 1
        _ = cache.value(for: "c")                   // a and c both have 2; a was used less recently
        cache.setValue(4, for: "d")                 // evicts a
        #expect(cache.value(for: "a") == nil)
        #expect(cache.value(for: "c") == 3)
        #expect(cache.value(for: "d") == 4)
    }

    @Test("The example from the statement")
    func statementExample() {
        let cache = LFUCache.Cache<String, Int>(capacity: 3)
        cache.setValue(1, for: "smile")
        cache.setValue(2, for: "heart")
        cache.setValue(3, for: "thumbs")
        _ = cache.value(for: "smile")
        _ = cache.value(for: "smile")
        _ = cache.value(for: "heart")
        #expect(cache.evictionOrder == ["thumbs", "heart", "smile"])
        cache.setValue(4, for: "fire")
        _ = cache.value(for: "fire")
        #expect(cache.evictionOrder == ["heart", "fire", "smile"])
        cache.setValue(5, for: "star")
        #expect(cache.evictionOrder == ["star", "fire", "smile"])
        #expect(cache.frequency(of: "smile") == 3)
        #expect(cache.frequency(of: "fire") == 2)
        #expect(cache.frequency(of: "heart") == 0)
    }

    @Test("Updating a key is a use and never evicts")
    func updateCounts() {
        let cache = LFUCache.Cache<Int, String>(capacity: 2)
        cache.setValue("one", for: 1)
        cache.setValue("two", for: 2)
        cache.setValue("uno", for: 1)               // a use: 1 now has 2 uses
        #expect(cache.count == 2)
        #expect(cache.frequency(of: 1) == 2)
        cache.setValue("three", for: 3)             // evicts 2
        #expect(cache.value(for: 1) == "uno")
        #expect(cache.value(for: 2) == nil)
        #expect(cache.value(for: 3) == "three")
    }

    @Test("Misses and frequency(of:) don't count as uses")
    func missesAndPeeks() {
        let cache = LFUCache.Cache<Int, Int>(capacity: 2)
        cache.setValue(10, for: 1)
        cache.setValue(20, for: 2)
        #expect(cache.value(for: 99) == nil)
        #expect(cache.frequency(of: 1) == 1)
        #expect(cache.frequency(of: 1) == 1)
        #expect(cache.frequency(of: 99) == 0)
        #expect(cache.evictionOrder == [1, 2])
        cache.setValue(30, for: 3)                  // 1 and 2 tie at 1 use; 1 is older
        #expect(cache.evictionOrder == [2, 3])
    }

    @Test("Capacity 0 stores nothing, capacity 1 keeps only the newest key")
    func tinyCapacities() {
        let empty = LFUCache.Cache<Int, Int>(capacity: 0)
        empty.setValue(1, for: 1)
        #expect(empty.count == 0)
        #expect(empty.value(for: 1) == nil)
        #expect(empty.evictionOrder == [])

        let one = LFUCache.Cache<Int, Int>(capacity: 1)
        one.setValue(1, for: 1)
        _ = one.value(for: 1)
        _ = one.value(for: 1)
        one.setValue(2, for: 2)                     // must evict 1, however popular
        #expect(one.value(for: 1) == nil)
        #expect(one.value(for: 2) == 2)
        #expect(one.count == 1)
        #expect(one.evictionOrder == [2])
    }

    @Test("Matches a scanning model through thousands of operations", arguments: [1, 2, 3, 5, 8])
    func matchesModel(capacity: Int) {
        let cache = LFUCache.Cache<Int, Int>(capacity: capacity)
        var model = LFUModel(capacity: capacity)
        var seed = UInt64(capacity) &* 2_654_435_761
        for step in 0..<4_000 {
            seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            let roll = Int(seed >> 33)
            let key = roll % 14
            if roll % 3 == 0 {
                cache.setValue(step, for: key)
                model.setValue(step, for: key)
            } else {
                let expected = model.value(for: key)
                if cache.value(for: key) != expected {
                    Issue.record("value(for: \(key)) is wrong at step \(step)")
                    return
                }
            }
            if cache.evictionOrder != model.evictionOrder {
                Issue.record("evictionOrder is wrong at step \(step): \(cache.evictionOrder), expected \(model.evictionOrder)")
                return
            }
            if cache.frequency(of: key) != (model.entries.first { $0.key == key }?.frequency ?? 0) {
                Issue.record("frequency(of: \(key)) is wrong at step \(step)")
                return
            }
        }
        #expect(cache.count == model.entries.count)
    }

    @Test("Doesn't keep values alive after eviction or after the cache is gone")
    func freesValues() {
        weak var evicted: Tile?
        weak var kept: Tile?
        do {
            let cache = LFUCache.Cache<String, Tile>(capacity: 2)
            do {
                let first = Tile("first")
                let second = Tile("second")
                evicted = first
                kept = second
                cache.setValue(first, for: "first")
                cache.setValue(second, for: "second")
            }
            _ = cache.value(for: "second")
            cache.setValue(Tile("third"), for: "third")     // first has the fewest uses
            #expect(evicted == nil, "an evicted value should be freed")
            #expect(kept?.name == "second")
        }
        #expect(kept == nil, "freeing the cache should free every node; check for a retain cycle")
    }

    @Test("Over 100,000 operations on 50,000 entries stay O(1) each")
    func large() {
        let n = 50_000
        let cache = LFUCache.Cache<Int, Int>(capacity: n)
        for key in 0..<n {
            cache.setValue(key, for: key)
        }
        // Use the even keys once more, and every tenth key twice more
        for key in stride(from: 0, to: n, by: 2) {
            _ = cache.value(for: key)
        }
        for key in stride(from: 0, to: n, by: 10) {
            _ = cache.value(for: key)
            _ = cache.value(for: key)
        }
        // 50,000 new keys: each evicts the least used, oldest first. The 25,000 odd keys (1 use) go first,
        // and then the new keys themselves, each with 1 use, push each other out.
        for key in n..<(2 * n) {
            cache.setValue(-key, for: key)
        }
        #expect(cache.count == n)
        #expect(cache.value(for: 1) == nil)
        #expect(cache.value(for: 49_999) == nil)
        #expect(cache.value(for: 2) == 2)
        #expect(cache.value(for: 10) == 10)
        #expect(cache.frequency(of: 10) == 5)
        #expect(cache.frequency(of: 4) == 2)
        #expect(cache.value(for: 2 * n - 1) == -(2 * n - 1))
        #expect(cache.value(for: n) == nil)                  // a new key, pushed out by later new keys
        #expect(cache.evictionOrder.count == n)
    }
}
