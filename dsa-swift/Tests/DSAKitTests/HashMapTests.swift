import Testing
import DSAKit

@Suite struct HashMapTests {
    /// A key whose hash ignores everything but `value % 3`, so most keys collide. Equality still
    /// compares the whole value, so the map must tell colliding keys apart with `==`.
    private struct BadKey: Hashable {
        var value: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(value % 3)
        }
    }

    /// Every instance hashes the same: the worst case, one long chain.
    private struct ConstantKey: Hashable {
        var name: String

        func hash(into hasher: inout Hasher) {
            hasher.combine(0)
        }
    }

    @Test("A new map is empty")
    func startsEmpty() {
        let map = HashMap<String, Int>()
        #expect(map.isEmpty)
        #expect(map.count == 0)
        #expect(map["missing"] == nil)
        #expect(map.bucketCount == HashMap<String, Int>.minimumBucketCount)
        #expect(Array(map.keys).isEmpty)
        #expect(map.description == "[:]")
    }

    @Test("Stores and reads values")
    func storesAndReads() {
        var map = HashMap<String, Int>()
        map["one"] = 1
        map["two"] = 2
        #expect(map["one"] == 1)
        #expect(map["two"] == 2)
        #expect(map["three"] == nil)
        #expect(map.count == 2)
        #expect(!map.isEmpty)
        #expect(map.contains(key: "two"))
        #expect(!map.contains(key: "three"))
    }

    @Test("Assigning to an existing key replaces its value without changing the count")
    func overwrites() {
        var map = HashMap<String, Int>()
        map["a"] = 1
        map["a"] = 10
        #expect(map["a"] == 10)
        #expect(map.count == 1)
        #expect(map.updateValue(20, forKey: "a") == 10)
        #expect(map.updateValue(5, forKey: "b") == nil)
        #expect(map.count == 2)
    }

    @Test("Assigning nil and removeValue(forKey:) remove keys")
    func removes() {
        var map: HashMap = ["a": 1, "b": 2, "c": 3]
        map["b"] = nil
        #expect(map["b"] == nil)
        #expect(map.count == 2)
        #expect(map.removeValue(forKey: "a") == 1)
        #expect(map.removeValue(forKey: "a") == nil)
        #expect(map.removeValue(forKey: "zzz") == nil)
        map["missing"] = nil
        #expect(map.count == 1)
        #expect(map["c"] == 3)
        map["a"] = 100
        #expect(map["a"] == 100)
        #expect(map.count == 2)
    }

    @Test("The default subscript counts in place")
    func defaultSubscript() {
        var counts = HashMap<Character, Int>()
        for letter in "mississippi" {
            counts[letter, default: 0] += 1
        }
        #expect(counts["s"] == 4)
        #expect(counts["i"] == 4)
        #expect(counts["p"] == 2)
        #expect(counts["m"] == 1)
        #expect(counts["z", default: 0] == 0)
        #expect(counts.count == 4)
    }

    @Test("Thousands of insertions grow the buckets and keep the load factor at most 0.75")
    func growsPastTheLoadFactor() {
        var map = HashMap<Int, Int>()
        var bucketCounts: [Int] = [map.bucketCount]
        for key in 0..<10_000 {
            map[key] = key * key
            #expect(map.loadFactor <= 0.75)
            if map.bucketCount != bucketCounts.last {
                bucketCounts.append(map.bucketCount)
            }
        }
        #expect(map.count == 10_000)
        #expect(bucketCounts == [8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384])
        var wrong = 0
        for key in 0..<10_000 where map[key] != key * key {
            wrong += 1
        }
        #expect(wrong == 0)
        #expect(map[10_000] == nil)
        #expect(map[-1] == nil)
    }

    @Test("Removing half of many keys leaves exactly the other half")
    func manyRemovals() {
        var map = HashMap<Int, String>()
        for key in 0..<5_000 {
            map[key] = String(key)
        }
        for key in stride(from: 0, to: 5_000, by: 2) {
            #expect(map.removeValue(forKey: key) == String(key))
        }
        #expect(map.count == 2_500)
        #expect(Set(map.keys) == Set(stride(from: 1, to: 5_000, by: 2)))
        #expect(map[2] == nil)
        #expect(map[4_999] == "4999")
    }

    @Test("Colliding keys are kept apart by ==")
    func collisions() {
        var map = HashMap<BadKey, Int>()
        for value in 0..<300 {
            map[BadKey(value: value)] = value
        }
        #expect(map.count == 300)
        #expect(map.longestChain >= 100)
        #expect(map[BadKey(value: 299)] == 299)
        #expect(map[BadKey(value: 300)] == nil)
        map[BadKey(value: 3)] = nil
        #expect(map[BadKey(value: 3)] == nil)
        #expect(map[BadKey(value: 6)] == 6)
        #expect(map[BadKey(value: 0)] == 0)
        map[BadKey(value: 6)] = -6
        #expect(map[BadKey(value: 6)] == -6)
        #expect(map.count == 299)
    }

    @Test("Still correct when every key has the same hash")
    func constantHash() {
        var map = HashMap<ConstantKey, Int>()
        let names = ["ant", "bee", "cat", "dog", "eel", "fox", "gnu", "hen", "ibis", "jay"]
        for (index, name) in names.enumerated() {
            map[ConstantKey(name: name)] = index
        }
        #expect(map.longestChain == names.count)
        for (index, name) in names.enumerated() {
            #expect(map[ConstantKey(name: name)] == index)
        }
        #expect(map.removeValue(forKey: ConstantKey(name: "cat")) == 2)
        #expect(map[ConstantKey(name: "cat")] == nil)
        #expect(map[ConstantKey(name: "jay")] == 9)
        #expect(map.count == names.count - 1)
    }

    @Test("A dictionary literal builds the map, and a repeated key keeps its last value")
    func literal() {
        let map: HashMap = ["x": 1, "y": 2, "x": 3]
        #expect(map.count == 2)
        #expect(map["x"] == 3)
        #expect(map["y"] == 2)
        let empty: HashMap<String, Int> = [:]
        #expect(empty.isEmpty)
    }

    @Test("Iterating visits every pair once, and keys and values line up")
    func iteration() {
        let map: HashMap = [1: "one", 2: "two", 3: "three", 40: "forty"]
        #expect(map.map(\.key).sorted() == [1, 2, 3, 40])
        #expect(Array(map.keys).sorted() == [1, 2, 3, 40])
        #expect(Array(map.values).sorted() == ["forty", "one", "three", "two"])
        for (key, value) in zip(map.keys, map.values) {
            #expect(map[key] == value)
        }
        #expect(map.underestimatedCount == 4)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original: HashMap = ["a": 1]
        var copy = original
        copy["a"] = 2
        copy["b"] = 3
        original["c"] = 4
        #expect(original["a"] == 1)
        #expect(original["b"] == nil)
        #expect(copy["c"] == nil)
        #expect(copy.count == 2)
    }

    @Test("Equality ignores insertion order and bucket layout")
    func equality() {
        var first = HashMap<Int, Int>()
        for key in 0..<100 {
            first[key] = key
        }
        var second = HashMap<Int, Int>(minimumCapacity: 1_000)
        for key in (0..<100).reversed() {
            second[key] = key
        }
        #expect(first == second)
        second[50] = -1
        #expect(first != second)
        second[50] = nil
        #expect(first != second)
    }

    @Test("minimumCapacity avoids growing, and removeAll empties the map")
    func capacityAndRemoveAll() {
        var map = HashMap<Int, Int>(minimumCapacity: 100)
        let buckets = map.bucketCount
        #expect(buckets >= 128)
        for key in 0..<100 {
            map[key] = key
        }
        #expect(map.bucketCount == buckets)
        map.removeAll()
        #expect(map.isEmpty)
        #expect(map[5] == nil)
        #expect(map.bucketCount == HashMap<Int, Int>.minimumBucketCount)
    }

    @Test("Builds from a sequence of pairs, and describes itself like a dictionary")
    func pairsAndDescription() {
        let map = HashMap(zip(["a", "b", "a"], [1, 2, 3]))
        #expect(map.count == 2)
        #expect(map["a"] == 3)
        let single: HashMap = ["key": 7]
        #expect(single.description == "[\"key\": 7]")
    }
}
