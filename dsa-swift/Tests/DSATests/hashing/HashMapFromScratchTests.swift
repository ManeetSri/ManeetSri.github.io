import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct HashMapFromScratchTests {
    typealias Map = HashMapFromScratch.Map

    /// Only `value % 4` goes into the hash, so most keys collide; == still compares the whole value.
    private struct CollidingKey: Hashable {
        var value: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(value % 4)
        }
    }

    @Test("A new map is empty with 8 buckets")
    func startsEmpty() {
        let map = Map<String, Int>()
        #expect(map.count == 0)
        #expect(map.isEmpty)
        #expect(map.bucketCount == 8)
        #expect(map["anything"] == nil)
        #expect(map.keys.isEmpty)
    }

    @Test("Stores, reads and replaces values")
    func storesAndReplaces() {
        var map = Map<String, Int>()
        map["apple"] = 3
        map["pear"] = 5
        #expect(map["apple"] == 3)
        #expect(map["pear"] == 5)
        #expect(map["plum"] == nil)
        #expect(map.count == 2)
        #expect(!map.isEmpty)
        map["apple"] = 10
        #expect(map["apple"] == 10)
        #expect(map.count == 2)
    }

    @Test("Assigning nil and removeValue(forKey:) remove keys")
    func removes() {
        var map = Map<String, Int>()
        map["a"] = 1
        map["b"] = 2
        map["c"] = 3
        map["b"] = nil
        #expect(map["b"] == nil)
        #expect(map.count == 2)
        #expect(map.removeValue(forKey: "a") == 1)
        #expect(map.removeValue(forKey: "a") == nil)
        #expect(map.removeValue(forKey: "never") == nil)
        map["never"] = nil
        #expect(map.count == 1)
        #expect(map["c"] == 3)
        #expect(map.keys == ["c"])
        map["a"] = 7
        #expect(map["a"] == 7)
        #expect(map.count == 2)
    }

    @Test("Doubles its buckets as soon as the load factor passes 3/4")
    func growth() {
        var map = Map<Int, Int>()
        var sizes: [Int] = []
        for key in 1...100 {
            map[key] = key
            sizes.append(map.bucketCount)
        }
        #expect(sizes[5] == 8)     // 6 keys: 6 ≤ 6
        #expect(sizes[6] == 16)    // 7 keys: 7 > 6
        #expect(sizes[11] == 16)   // 12 keys: 12 ≤ 12
        #expect(sizes[12] == 32)   // 13 keys
        #expect(sizes[47] == 64)   // 48 keys: 48 ≤ 48
        #expect(sizes[48] == 128)  // 49 keys: 49 > 48
        #expect(sizes[96] == 256)  // 97 keys: 97 > 96
        // Replacing a value isn't an insertion, so it never grows the map
        for key in 1...100 {
            map[key] = -key
        }
        #expect(map.bucketCount == 256)
        #expect(map.count == 100)
    }

    @Test("Never shrinks")
    func neverShrinks() {
        var map = Map<Int, Int>()
        for key in 0..<50 {
            map[key] = key
        }
        let grown = map.bucketCount
        for key in 0..<50 {
            map[key] = nil
        }
        #expect(map.isEmpty)
        #expect(map.bucketCount == grown)
    }

    @Test("Keeps every value through thousands of insertions and resizes")
    func thousands() {
        var map = Map<Int, String>()
        for key in 0..<20_000 {
            map[key * 3] = String(key)
        }
        #expect(map.count == 20_000)
        #expect(map.bucketCount == 32_768)
        var wrong = 0
        for key in 0..<20_000 where map[key * 3] != String(key) {
            wrong += 1
        }
        #expect(wrong == 0)
        #expect(map[1] == nil)
        #expect(map[60_000] == nil)
        #expect(Set(map.keys) == Set((0..<20_000).map { $0 * 3 }))
    }

    @Test("Removing half the keys leaves exactly the other half")
    func removeHalf() {
        var map = Map<String, Int>()
        for number in 0..<2_000 {
            map["key\(number)"] = number
        }
        var wrongRemovals = 0
        for number in stride(from: 0, to: 2_000, by: 2) where map.removeValue(forKey: "key\(number)") != number {
            wrongRemovals += 1
        }
        #expect(wrongRemovals == 0)
        #expect(map.count == 1_000)
        #expect(map["key10"] == nil)
        #expect(map["key11"] == 11)
        #expect(map.keys.count == 1_000)
    }

    @Test("Colliding keys stay separate")
    func collisions() {
        var map = Map<CollidingKey, Int>()
        for value in 0..<200 {
            map[CollidingKey(value: value)] = value * 10
        }
        #expect(map.count == 200)
        #expect(map[CollidingKey(value: 199)] == 1_990)
        #expect(map[CollidingKey(value: 4)] == 40)
        #expect(map[CollidingKey(value: 200)] == nil)
        map[CollidingKey(value: 4)] = nil
        #expect(map[CollidingKey(value: 4)] == nil)
        #expect(map[CollidingKey(value: 8)] == 80)
        #expect(map[CollidingKey(value: 0)] == 0)
        #expect(map.count == 199)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original = Map<String, Int>()
        original["a"] = 1
        var copy = original
        copy["a"] = 2
        copy["b"] = 3
        #expect(original["a"] == 1)
        #expect(original["b"] == nil)
        #expect(original.count == 1)
        #expect(copy.count == 2)
    }
}
