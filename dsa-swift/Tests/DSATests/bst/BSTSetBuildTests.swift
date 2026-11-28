import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BSTSetBuildTests {
    typealias SearchTreeSet = BSTSetBuild.SearchTreeSet

    /// A tiny deterministic generator, so the mixed-operation test does the same thing every run.
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

    /// 50 at the root; 30 and 70; 20, 40, 60 and 80; then 35, 45, 65 and 75.
    static let sampleOrder = [50, 30, 70, 20, 40, 60, 80, 35, 45, 65, 75]

    static func sample() -> SearchTreeSet<Int> {
        var set = SearchTreeSet<Int>()
        for value in sampleOrder {
            set.insert(value)
        }
        return set
    }

    @Test("A new set is empty")
    func startsEmpty() {
        var set = SearchTreeSet<Int>()
        #expect(set.isEmpty)
        #expect(set.count == 0)
        #expect(set.min == nil && set.max == nil)
        #expect(set.floor(1) == nil && set.ceiling(1) == nil)
        #expect(!set.contains(1))
        #expect(set.remove(1) == nil)
        #expect(set.inOrder == [])
    }

    @Test("insert reports whether the element was new")
    func insertAndDuplicates() {
        var set = SearchTreeSet<Int>()
        #expect(set.insert(5) == true)
        #expect(set.insert(2) == true)
        #expect(set.insert(5) == false)
        #expect(set.count == 2)
        #expect(!set.isEmpty)
        #expect(set.contains(2) && set.contains(5) && !set.contains(3))
        #expect(set.inOrder == [2, 5])
    }

    @Test("Elements come out in increasing order")
    func sortedOrder() {
        let set = Self.sample()
        #expect(set.inOrder == Self.sampleOrder.sorted())
        #expect(set.count == 11)
        #expect(set.min == 20)
        #expect(set.max == 80)
    }

    @Test("Removing leaves, one-child nodes and two-child nodes", arguments: [
        [35], [75], [20, 30], [60], [80], [30], [40], [70], [50], [50, 60, 65, 70],
    ])
    func removes(values: [Int]) {
        var set = Self.sample()
        var expected = Self.sampleOrder.sorted()
        for value in values {
            #expect(set.remove(value) == value)
            expected.removeAll { $0 == value }
        }
        #expect(set.inOrder == expected)
        #expect(set.count == expected.count)
        #expect(set.remove(values[0]) == nil)
        for value in expected {
            #expect(set.contains(value))
        }
    }

    @Test("Removing everything, root first, then using the set again")
    func removeEverything() {
        var set = Self.sample()
        for value in Self.sampleOrder {
            #expect(set.remove(value) == value)
        }
        #expect(set.isEmpty && set.count == 0 && set.inOrder == [])
        #expect(set.insert(3) == true)
        #expect(set.inOrder == [3])
    }

    @Test("floor and ceiling at the edges", arguments: [
        (5, nil, 20), (20, 20, 20), (25, 20, 30), (40, 40, 40), (47, 45, 50),
        (79, 75, 80), (80, 80, 80), (81, 80, nil), (Int.max, 80, nil), (Int.min, nil, 20),
    ] as [(Int, Int?, Int?)])
    func floorAndCeiling(probe: Int, floor: Int?, ceiling: Int?) {
        let set = Self.sample()
        #expect(set.floor(probe) == floor)
        #expect(set.ceiling(probe) == ceiling)
    }

    @Test("Works for any Comparable element")
    func strings() {
        var words = SearchTreeSet<String>()
        for word in ["mango", "apple", "cherry", "plum", "apple"] {
            words.insert(word)
        }
        #expect(words.inOrder == ["apple", "cherry", "mango", "plum"])
        #expect(words.floor("banana") == "apple")
        #expect(words.ceiling("banana") == "cherry")
        #expect(words.remove("mango") == "mango")
        #expect(words.min == "apple" && words.max == "plum")
    }

    @Test("1,000 sorted insertions make a chain that still works")
    func chain() {
        var set = SearchTreeSet<Int>()
        for value in 1...1_000 {
            set.insert(value)
        }
        #expect(set.count == 1_000)
        #expect(set.max == 1_000)
        #expect(set.floor(2_000) == 1_000)
        #expect(set.remove(1_000) == 1_000)
        #expect(set.remove(1) == 1)
        #expect(set.inOrder == Array(2...999))
    }

    @Test("Thousands of random operations match a Set and a sorted array")
    func matchesModel() {
        var steps = Steps(seed: 37)
        var set = SearchTreeSet<Int>()
        var model = Set<Int>()
        var sorted: [Int] = []
        var mismatches: [String] = []

        func check(_ condition: Bool, _ message: @autoclosure () -> String) {
            if !condition && mismatches.count < 5 {
                mismatches.append(message())
            }
        }

        for step in 0..<5_000 {
            let value = steps.next(below: 300) - 150
            switch steps.next(below: 9) {
            case 0...3:
                let inserted = model.insert(value).inserted
                if inserted {
                    sorted.insert(value, at: sorted.firstIndex { $0 > value } ?? sorted.count)
                }
                check(set.insert(value) == inserted, "insert \(value) at step \(step)")
            case 4...6:
                let removed = model.remove(value)
                sorted.removeAll { $0 == value }
                check(set.remove(value) == removed, "remove \(value) at step \(step)")
            case 7:
                check(set.contains(value) == model.contains(value), "contains \(value) at step \(step)")
                check(set.floor(value) == sorted.last { $0 <= value }, "floor \(value) at step \(step)")
                check(set.ceiling(value) == sorted.first { $0 >= value }, "ceiling \(value) at step \(step)")
            default:
                check(set.min == sorted.first && set.max == sorted.last, "min and max at step \(step)")
                check(set.count == model.count, "count at step \(step)")
            }
            if step % 250 == 0 {
                check(set.inOrder == sorted, "contents at step \(step)")
            }
        }
        check(set.inOrder == sorted, "final contents")
        #expect(mismatches == [])
    }

    @Test("50,000 elements in a scrambled order")
    func large() {
        var set = SearchTreeSet<Int>()
        let n = 50_000
        for i in 0..<n {
            set.insert((i * 7_919) % n)                  // every value once, in a scrambled order
        }
        #expect(set.count == n)
        let allThere = set.inOrder == Array(0..<n)
        #expect(allThere)
        for value in stride(from: 0, to: n, by: 3) {
            set.remove(value)
        }
        let rightOnesLeft = set.inOrder == (0..<n).filter { $0 % 3 != 0 }
        #expect(rightOnesLeft)
        #expect(set.floor(n) == n - 1)
        #expect(set.ceiling(0) == 1)
    }
}
