import Testing
@testable import DSAKit

@Suite struct SkipListTests {
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

    @Test("A new skip list is empty")
    func empty() {
        var list = SkipList<Int>()
        #expect(list.isEmpty)
        #expect(list.count == 0)
        #expect(list.height == 1)
        #expect(list.first == nil)
        #expect(list.last == nil)
        #expect(list.popFirst() == nil)
        #expect(list.floor(1) == nil)
        #expect(list.ceiling(1) == nil)
        #expect(list.predecessor(of: 1) == nil)
        #expect(list.successor(of: 1) == nil)
        #expect(list.elements(in: 0...10) == [])
        #expect(!list.contains(0))
        #expect(list.remove(0) == nil)
        #expect(Array(list) == [])
        #expect(list.description == "SkipList([])")
        #expect(list.isConsistent)
    }

    @Test("A single element")
    func single() {
        var list = SkipList<String>(seed: 1)
        #expect(list.insert("swift") == true)
        #expect(list.insert("swift") == false)
        #expect(list.count == 1)
        #expect(list.first == "swift")
        #expect(list.last == "swift")
        #expect(list.floor("z") == "swift")
        #expect(list.ceiling("a") == "swift")
        #expect(list.remove("swift") == "swift")
        #expect(list.isEmpty)
        #expect(list.height == 1)
    }

    @Test("Keeps elements sorted and stores each once")
    func sortedAndDistinct() {
        var list: SkipList = [5, 1, 4, 1, 5, 9, 2, 6]
        #expect(Array(list) == [1, 2, 4, 5, 6, 9])
        #expect(list.insert(3) == true)
        #expect(list.insert(3) == false)
        #expect(list.count == 7)
        #expect(list.first == 1)
        #expect(list.last == 9)
        #expect(list.contains(4))
        #expect(!list.contains(7))
        #expect(list.remove(4) == 4)
        #expect(list.remove(4) == nil)
        #expect(list.description == "SkipList([1, 2, 3, 5, 6, 9])")
        #expect(list.popFirst() == 1)
        #expect(list.first == 2)
        #expect(list.isConsistent)
    }

    @Test("floor, ceiling, predecessor and successor at the edges")
    func neighbours() {
        let list = SkipList([10, 20, 30], seed: 7)
        #expect(list.floor(9) == nil)
        #expect(list.floor(10) == 10)
        #expect(list.floor(19) == 10)
        #expect(list.floor(99) == 30)
        #expect(list.ceiling(31) == nil)
        #expect(list.ceiling(30) == 30)
        #expect(list.ceiling(11) == 20)
        #expect(list.ceiling(-5) == 10)
        #expect(list.predecessor(of: 20) == 10)
        #expect(list.predecessor(of: 21) == 20)
        #expect(list.predecessor(of: 10) == nil)
        #expect(list.successor(of: 20) == 30)
        #expect(list.successor(of: 19) == 20)
        #expect(list.successor(of: 30) == nil)
    }

    @Test("Range queries include the right ends", arguments: [
        (0...100, [10, 20, 30, 40]), (20...30, [20, 30]), (21...29, []), (35...35, []), (40...40, [40]), (41...90, []),
    ] as [(ClosedRange<Int>, [Int])])
    func closedRanges(range: ClosedRange<Int>, expected: [Int]) {
        let list: SkipList = [40, 10, 30, 20]
        #expect(list.elements(in: range) == expected)
    }

    @Test("Half-open ranges leave out the upper bound")
    func halfOpenRanges() {
        let list: SkipList = [40, 10, 30, 20]
        #expect(list.elements(in: 10..<30) == [10, 20])
        #expect(list.elements(in: 11..<41) == [20, 30, 40])
        #expect(list.elements(in: 20..<20) == [])
    }

    @Test("The same seed builds the same levels; heights don't affect equality")
    func seeds() {
        let a = SkipList(0..<500, seed: 11)
        let b = SkipList(0..<500, seed: 11)
        let c = SkipList((0..<500).reversed(), seed: 99)
        #expect(a.levelSizes == b.levelSizes)
        #expect(a == c)
        #expect(a != SkipList(0..<499, seed: 11))
    }

    @Test("Levels thin out by about half, and the height grows like log n")
    func levelShape() {
        let list = SkipList(0..<20_000, seed: 2024)
        let sizes = list.levelSizes
        #expect(sizes[0] == 20_000)
        #expect(sizes[1] > 9_000 && sizes[1] < 11_000)
        #expect(sizes[2] > 4_300 && sizes[2] < 5_700)
        #expect(list.height >= 12 && list.height <= 26)
        #expect(zip(sizes, sizes.dropFirst()).allSatisfy { $0 >= $1 })
        #expect(list.isConsistent)
    }

    @Test("Random operations match a Set and a sorted array")
    func randomOperations() {
        var steps = Steps(seed: 64)
        var list = SkipList<Int>(seed: 3)
        var model = Set<Int>()
        for step in 0..<5_000 {
            let value = steps.next(below: 300) - 150
            switch steps.next(below: 5) {
            case 0, 1:
                if list.insert(value) != model.insert(value).inserted {
                    Issue.record("insert(\(value)) returned the wrong answer at step \(step)")
                    return
                }
            case 2:
                if (list.remove(value) != nil) != (model.remove(value) != nil) {
                    Issue.record("remove(\(value)) returned the wrong answer at step \(step)")
                    return
                }
            case 3:
                let sorted = model.sorted()
                let low = value, high = value + steps.next(below: 40)
                if list.elements(in: low...high) != sorted.filter({ (low...high).contains($0) })
                    || list.floor(value) != sorted.last(where: { $0 <= value })
                    || list.successor(of: value) != sorted.first(where: { $0 > value }) {
                    Issue.record("a query around \(value) is wrong at step \(step)")
                    return
                }
            default:
                if list.contains(value) != model.contains(value) || list.first != model.min() || list.last != model.max() {
                    Issue.record("contains, first or last is wrong at step \(step)")
                    return
                }
            }
            if list.count != model.count {
                Issue.record("count is wrong at step \(step)")
                return
            }
        }
        #expect(Array(list) == model.sorted())
        #expect(list.isConsistent)
    }

    @Test("Removed slots are reused, and removeAll empties the set")
    func reuseAndRemoveAll() {
        var list = SkipList(0..<100, seed: 5)
        for value in 0..<100 where value % 2 == 0 {
            list.remove(value)
        }
        let storage = list.values.count
        for value in 200..<250 {
            list.insert(value)
        }
        #expect(list.values.count == storage, "the 50 freed slots hold the 50 new elements")
        #expect(list.count == 100)
        #expect(list.isConsistent)
        list.removeAll()
        #expect(list.isEmpty)
        #expect(list.height == 1)
        #expect(Array(list) == [])
        list.insert(1)
        #expect(Array(list) == [1])
    }

    @Test("Copies are independent, and iterating sees the set as it was")
    func valueSemantics() {
        var original: SkipList = [1, 2, 3]
        var copy = original
        copy.insert(4)
        original.remove(1)
        #expect(Array(original) == [2, 3])
        #expect(Array(copy) == [1, 2, 3, 4])

        var seen: [Int] = []
        for element in copy {
            seen.append(element)
            copy.insert(element + 100)
        }
        #expect(seen == [1, 2, 3, 4])
        #expect(copy.count == 8)
    }

    @Test("A large list built from sorted input stays fast")
    func large() {
        var list = SkipList<Int>(seed: 77)
        for value in 0..<100_000 {
            list.insert(value * 3)
        }
        #expect(list.count == 100_000)
        #expect(list.contains(150_000))
        #expect(!list.contains(150_001))
        #expect(list.floor(150_001) == 150_000)
        #expect(list.ceiling(150_001) == 150_003)
        #expect(list.last == 299_997)
        #expect(list.elements(in: 3_000...3_012) == [3_000, 3_003, 3_006, 3_009, 3_012])
        for value in stride(from: 0, to: 300_000, by: 6) {
            list.remove(value)
        }
        #expect(list.count == 50_000)
        #expect(list.first == 3)
        #expect(list.height <= 30)
    }
}
