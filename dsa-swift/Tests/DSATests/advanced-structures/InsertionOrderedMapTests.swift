import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct OrderedMapRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct InsertionOrderedMapTests {
    @Test("The examples")
    func examples() {
        var map = InsertionOrderedMap.Map<String, Int>()
        map["volume"] = 7
        map["contrast"] = 3
        map["volume"] = 9
        #expect(map.keys == ["volume", "contrast"])
        #expect(map.values == [9, 3])
        map["brightness"] = 50
        #expect(map.removeValue(forKey: "volume") == 9)
        #expect(map.keys == ["contrast", "brightness"])
        map["volume"] = 1
        #expect(map.keys == ["contrast", "brightness", "volume"])
        let first = map.popFirst()
        #expect(first?.key == "contrast" && first?.value == 3)
        #expect(map.count == 2)
        map["brightness"] = nil
        #expect(map["missing"] == nil)
        #expect(map.keys == ["volume"])
        #expect(map["volume"] == 1)
        var empty = InsertionOrderedMap.Map<Int, Int>()
        #expect(empty.popFirst() == nil)
        #expect(empty.count == 0 && empty.keys.isEmpty && empty.values.isEmpty)
    }

    @Test("Removing a missing key, and draining everything")
    func drain() {
        var map = InsertionOrderedMap.Map<Int, String>()
        #expect(map.removeValue(forKey: 4) == nil)
        for i in 0..<40 {
            map[i] = "item \(i)"
        }
        #expect(map.count == 40)
        var popped: [Int] = []
        while let entry = map.popFirst() {
            popped.append(entry.key)
            #expect(entry.value == "item \(entry.key)")
            if popped.count > 40 { break }
        }
        #expect(popped == Array(0..<40))
        #expect(map.count == 0 && map.keys.isEmpty)
        map[7] = "again"
        #expect(map.keys == [7] && map[7] == "again")
    }

    @Test("Copies are independent")
    func copies() {
        var original = InsertionOrderedMap.Map<String, Int>()
        original["a"] = 1
        original["b"] = 2
        var copy = original
        copy["a"] = 10
        copy.removeValue(forKey: "b")
        copy["c"] = 3
        #expect(original.keys == ["a", "b"] && original.values == [1, 2])
        #expect(copy.keys == ["a", "c"] && copy.values == [10, 3])
    }

    @Test("Random operations match an array-based ordered map", arguments: [1, 2, 3])
    func matchesReference(seed: UInt64) {
        var random = OrderedMapRandom(seed: seed)
        var map = InsertionOrderedMap.Map<Int, Int>()
        var order: [Int] = []                     // the reference: keys in order, and their values
        var values: [Int: Int] = [:]
        for step in 0..<3_000 {
            let key = Int.random(in: 0..<60, using: &random)
            switch Int.random(in: 0..<10, using: &random) {
            case 0...4:
                let value = Int.random(in: 0...1_000, using: &random)
                if values[key] == nil { order.append(key) }
                values[key] = value
                map[key] = value
            case 5...6:
                let removed = map.removeValue(forKey: key)
                #expect(removed == values[key], "step \(step): removeValue(forKey: \(key))")
                if values.removeValue(forKey: key) != nil { order.removeAll { $0 == key } }
            case 7:
                let entry = map.popFirst()
                if let oldest = order.first {
                    #expect(entry?.key == oldest && entry?.value == values[oldest], "step \(step): popFirst")
                    order.removeFirst()
                    values[oldest] = nil
                } else {
                    #expect(entry == nil, "step \(step): popFirst on an empty map")
                }
            case 8:
                map[key] = nil
                if values.removeValue(forKey: key) != nil { order.removeAll { $0 == key } }
            default:
                #expect(map[key] == values[key], "step \(step): map[\(key)]")
            }
            if step % 100 == 0 {
                #expect(map.keys == order, "step \(step): keys")
                #expect(map.values == order.map { values[$0]! }, "step \(step): values")
                #expect(map.count == order.count)
                if map.keys != order || map.count != order.count { return }
            }
        }
    }

    @Test("300,000 keys, half popped from the front and more removed from the middle")
    func large() {
        var map = InsertionOrderedMap.Map<Int, Int>()
        let n = 300_000
        for i in 0..<n {
            map[i] = i * 2
        }
        #expect(map.count == n)
        for i in 0..<(n / 2) {
            guard let entry = map.popFirst() else {
                Issue.record("popFirst returned nil with \(n - i) entries left")
                return
            }
            if entry.key != i {
                Issue.record("pop \(i) returned key \(entry.key)")
                return
            }
        }
        // Remove every third remaining key, update every seventh, and add a few back at the end
        var removed = 0
        for i in stride(from: n / 2, to: n, by: 3) {
            if map.removeValue(forKey: i) == i * 2 { removed += 1 }
        }
        #expect(removed == (n / 2 + 2) / 3)
        for i in stride(from: n / 2 + 1, to: n, by: 7) where map[i] != nil {
            map[i] = -i
        }
        map[0] = 0
        map[n / 2] = 1
        let expected = (n / 2..<n).filter { ($0 - n / 2) % 3 != 0 } + [0, n / 2]
        #expect(map.keys == expected)
        #expect(map.count == expected.count)
        #expect(map[n / 2 + 1] == -(n / 2 + 1))
        #expect(map[n / 2 + 2] == (n / 2 + 2) * 2)
        #expect(map.popFirst()?.key == n / 2 + 1)
    }

    @Test("Adding and removing forever keeps working (tombstones are cleaned up)")
    func churn() {
        var map = InsertionOrderedMap.Map<Int, Int>()
        for i in 0..<200_000 {
            map[i] = i
            if i >= 10 {
                map.removeValue(forKey: i - 10)
            }
        }
        #expect(map.count == 10)
        #expect(map.keys == Array(199_990..<200_000))
    }
}
