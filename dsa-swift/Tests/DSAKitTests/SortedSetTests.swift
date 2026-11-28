import Testing
@testable import DSAKit

@Suite struct SortedSetTests {
    /// A tiny deterministic generator, so the random-operation tests do the same thing every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    // MARK: SortedSet

    @Test("A new set is empty")
    func emptySet() {
        var set = SortedSet<Int>()
        #expect(set.isEmpty)
        #expect(set.count == 0)
        #expect(set.first == nil)
        #expect(set.last == nil)
        #expect(set.popFirst() == nil)
        #expect(set.popLast() == nil)
        #expect(set.floor(1) == nil)
        #expect(set.ceiling(1) == nil)
        #expect(set.predecessor(of: 1) == nil)
        #expect(set.successor(of: 1) == nil)
        #expect(set.elements(in: 0...10) == [])
        #expect(Array(set) == [])
        #expect(set.description == "SortedSet([])")
    }

    @Test("Keeps elements sorted and stores each once")
    func sortedAndDistinct() {
        var set: SortedSet = [5, 1, 4, 1, 5, 9, 2, 6]
        #expect(Array(set) == [1, 2, 4, 5, 6, 9])
        #expect(set.insert(3) == true)
        #expect(set.insert(3) == false)
        #expect(set.count == 7)
        #expect(set.first == 1)
        #expect(set.last == 9)
        #expect(set.contains(4))
        #expect(!set.contains(7))
        #expect(set.remove(4) == 4)
        #expect(set.remove(4) == nil)
        #expect(set.description == "SortedSet([1, 2, 3, 5, 6, 9])")
    }

    @Test("popFirst and popLast drain the set from either end")
    func popEnds() {
        var set: SortedSet = [30, 10, 20, 40]
        #expect(set.popFirst() == 10)
        #expect(set.popLast() == 40)
        #expect(set.popFirst() == 20)
        #expect(set.popLast() == 30)
        #expect(set.popFirst() == nil)
        #expect(set.isEmpty)
    }

    @Test("floor, ceiling, predecessor and successor at the edges")
    func neighbours() {
        let set: SortedSet = [10, 20, 30]
        #expect(set.floor(9) == nil)
        #expect(set.floor(10) == 10)
        #expect(set.floor(19) == 10)
        #expect(set.floor(99) == 30)
        #expect(set.ceiling(31) == nil)
        #expect(set.ceiling(30) == 30)
        #expect(set.ceiling(11) == 20)
        #expect(set.ceiling(-5) == 10)
        #expect(set.predecessor(of: 20) == 10)
        #expect(set.predecessor(of: 21) == 20)
        #expect(set.predecessor(of: 10) == nil)
        #expect(set.successor(of: 20) == 30)
        #expect(set.successor(of: 19) == 20)
        #expect(set.successor(of: 30) == nil)
    }

    @Test("Range queries include the right ends", arguments: [
        (0, 100, [10, 20, 30, 40]),
        (10, 30, [10, 20, 30]),
        (11, 29, [20]),
        (12, 18, []),
        (41, 50, []),
        (-10, 9, []),
        (40, 40, [40]),
    ])
    func closedRanges(low: Int, high: Int, expected: [Int]) {
        let set: SortedSet = [10, 20, 30, 40]
        #expect(set.elements(in: low...high) == expected)
    }

    @Test("Half-open ranges leave out the upper bound")
    func halfOpenRanges() {
        let set: SortedSet = [10, 20, 30, 40]
        #expect(set.elements(in: 10..<30) == [10, 20])
        #expect(set.elements(in: 20..<20) == [])
        #expect(set.elements(in: 15..<41) == [20, 30, 40])
    }

    @Test("Random operations and range queries match a Set and a sorted array")
    func randomSet() {
        var steps = Steps(seed: 2_024)
        var set = SortedSet<Int>()
        var model = Set<Int>()
        var wrong = 0
        for round in 1...10_000 {
            let value = steps.next(below: 1_000)
            if steps.next(below: 3) < 2 {
                if set.insert(value) != model.insert(value).inserted { wrong += 1 }
            } else {
                if set.remove(value) != model.remove(value) { wrong += 1 }
            }
            if round % 250 == 0 {
                let sorted = model.sorted()
                if Array(set) != sorted || set.count != sorted.count { wrong += 1 }
                if set.first != sorted.first || set.last != sorted.last { wrong += 1 }
                let low = steps.next(below: 1_000)
                let high = low + steps.next(below: 200)
                if set.elements(in: low...high) != sorted.filter({ (low...high).contains($0) }) { wrong += 1 }
                if set.elements(in: low..<high) != sorted.filter({ (low..<high).contains($0) }) { wrong += 1 }
                if set.predecessor(of: low) != sorted.last(where: { $0 < low }) { wrong += 1 }
                if set.successor(of: low) != sorted.first(where: { $0 > low }) { wrong += 1 }
                if !set.isBalanced { wrong += 1 }
            }
        }
        #expect(wrong == 0)
    }

    @Test("Set copies are independent")
    func setValueSemantics() {
        let original: SortedSet = [1, 2, 3]
        var changed = original
        changed.insert(0)
        changed.remove(3)
        var popped = original
        popped.popLast()
        #expect(Array(original) == [1, 2, 3])
        #expect(Array(changed) == [0, 1, 2])
        #expect(Array(popped) == [1, 2])
        #expect(original == SortedSet([3, 2, 1]))
        #expect(original != changed)
    }

    // MARK: SortedMap

    @Test("A new map is empty")
    func emptyMap() {
        var map = SortedMap<Int, String>()
        #expect(map.isEmpty)
        #expect(map[1] == nil)
        #expect(map.first == nil)
        #expect(map.last == nil)
        #expect(map.floor(1) == nil)
        #expect(map.removeValue(forKey: 1) == nil)
        #expect(map.popFirst() == nil)
        #expect(map.keys == [])
        #expect(map.description == "SortedMap([])")
    }

    @Test("Subscripts insert, overwrite and remove")
    func subscripts() {
        var map = SortedMap<Int, String>()
        map[20] = "b"
        map[10] = "a"
        map[30] = "c"
        #expect(map.keys == [10, 20, 30])
        #expect(map.values == ["a", "b", "c"])
        map[20] = "B"                                     // overwrite: same count, new value
        #expect(map.count == 3)
        #expect(map[20] == "B")
        map[10] = nil                                     // nil removes
        #expect(map.count == 2)
        #expect(map[10] == nil)
        map[99] = nil                                     // removing a missing key is fine
        #expect(map.count == 2)
        #expect(map.description == "SortedMap([20: \"B\", 30: \"c\"])")
    }

    @Test("updateValue and removeValue report the value they replace or remove")
    func overwriteSemantics() {
        var map: SortedMap = [1: "one"]
        #expect(map.updateValue("uno", forKey: 1) == "one")
        #expect(map.updateValue("dos", forKey: 2) == nil)
        #expect(map.count == 2)
        #expect(map[1] == "uno")
        #expect(map.removeValue(forKey: 1) == "uno")
        #expect(map.removeValue(forKey: 1) == nil)
        let repeated: SortedMap = [5: "first", 5: "last"]
        #expect(repeated.count == 1)
        #expect(repeated[5] == "last")
    }

    @Test("The default subscript counts occurrences")
    func defaultSubscript() {
        var counts = SortedMap<String, Int>()
        for word in ["b", "a", "b", "c", "b", "a"] {
            counts[word, default: 0] += 1
        }
        #expect(counts.keys == ["a", "b", "c"])
        #expect(counts.values == [2, 3, 1])
        #expect(counts["z", default: 0] == 0)
        #expect(counts["z"] == nil)                       // reading with a default stores nothing
    }

    @Test("floor, ceiling and their strict versions return whole entries")
    func mapNeighbours() {
        let prices: SortedMap = [10: 101, 20: 99, 30: 104]
        #expect(prices.floor(25)?.key == 20)
        #expect(prices.floor(25)?.value == 99)
        #expect(prices.floor(9) == nil)
        #expect(prices.ceiling(25)?.key == 30)
        #expect(prices.ceiling(31) == nil)
        #expect(prices.predecessor(of: 20)?.key == 10)
        #expect(prices.successor(of: 20)?.value == 104)
        #expect(prices.first?.key == 10)
        #expect(prices.last?.value == 104)
    }

    @Test("Range queries return entries in key order")
    func mapRanges() {
        let map: SortedMap = [5: "e", 1: "a", 3: "c", 4: "d", 2: "b"]
        #expect(map.elements(in: 2...4).map { $0.value } == ["b", "c", "d"])
        #expect(map.elements(in: 2..<4).map { $0.key } == [2, 3])
        #expect(map.elements(in: 6...9).isEmpty)
        #expect(map.map { $0.key } == [1, 2, 3, 4, 5])
    }

    @Test("Random operations match a Dictionary")
    func randomMap() {
        var steps = Steps(seed: 99)
        var map = SortedMap<Int, Int>()
        var model: [Int: Int] = [:]
        var wrong = 0
        for round in 1...10_000 {
            let key = steps.next(below: 500)
            let value = steps.next(below: 1_000_000)
            switch steps.next(below: 4) {
            case 0, 1:
                if map.updateValue(value, forKey: key) != model.updateValue(value, forKey: key) { wrong += 1 }
            case 2:
                if map.removeValue(forKey: key) != model.removeValue(forKey: key) { wrong += 1 }
            default:
                if map[key] != model[key] { wrong += 1 }
            }
            if round % 500 == 0 {
                let keys = model.keys.sorted()
                if map.keys != keys || map.values != keys.map({ model[$0]! }) { wrong += 1 }
                if !map.isBalanced { wrong += 1 }
            }
        }
        #expect(wrong == 0)
    }

    @Test("Map copies are independent, even when only a value changes")
    func mapValueSemantics() {
        let original: SortedMap = [1: "a", 2: "b"]
        var overwritten = original
        overwritten[1] = "A"                              // changes a value in place, so it must copy first
        var defaulted = original
        defaulted[2, default: ""] += "!"
        var removed = original
        removed.removeValue(forKey: 2)
        #expect(original[1] == "a")
        #expect(original[2] == "b")
        #expect(overwritten[1] == "A")
        #expect(defaulted[2] == "b!")
        #expect(removed.count == 1)
        #expect(original.count == 2)
        #expect(original == SortedMap([(2, "b"), (1, "a")]))
        #expect(original != overwritten)
    }

    @Test("A large map stays balanced and answers floor queries")
    func largeMap() {
        var map = SortedMap<Int, Int>()
        for key in stride(from: 0, to: 200_000, by: 2) {
            map[key] = key * 10
        }
        #expect(map.count == 100_000)
        #expect(map.isBalanced)
        var wrong = 0
        for query in stride(from: 1, to: 200_000, by: 1_994) {      // odd, so between two keys
            if map.floor(query)?.key != query - 1 || map.ceiling(query)?.key != (query + 1 < 200_000 ? query + 1 : nil) {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
