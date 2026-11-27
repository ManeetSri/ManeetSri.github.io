import Testing
import DSAKit

@Suite struct EfficientSortTests {
    /// A tiny deterministic generator, so the randomised tests do the same thing every run.
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

    /// An element with a sort key and a tag recording where it started, for checking stability.
    private struct Tagged {
        let key: Int
        let tag: Int
    }

    private static func randomArray(count: Int, below limit: Int, seed: UInt64) -> [Int] {
        var steps = Steps(seed: seed)
        return (0..<count).map { _ in steps.next(below: limit) }
    }

    // MARK: mergeSorted

    @Test("mergeSorted handles empty and single-element arrays")
    func mergeSortedTiny() {
        #expect([Int]().mergeSorted() == [])
        #expect([7].mergeSorted() == [7])
        #expect([2, 1].mergeSorted() == [1, 2])
    }

    @Test("mergeSorted sorts small arrays, including duplicates and negatives")
    func mergeSortedSmall() {
        #expect([5, 2, 9, 1, 5, 6].mergeSorted() == [1, 2, 5, 5, 6, 9])
        #expect([3, -1, 0, -7, 3, 3].mergeSorted() == [-7, -1, 0, 3, 3, 3])
        #expect(["pear", "fig", "apple"].mergeSorted() == ["apple", "fig", "pear"])
        #expect([4, 4, 4, 4].mergeSorted() == [4, 4, 4, 4])
    }

    @Test("mergeSorted leaves the original alone")
    func mergeSortedReturnsCopy() {
        let numbers = [3, 1, 2]
        let sorted = numbers.mergeSorted()
        #expect(sorted == [1, 2, 3])
        #expect(numbers == [3, 1, 2])
    }

    @Test("mergeSorted follows a custom order")
    func mergeSortedCustomOrder() {
        #expect([15, 3, 42, 8, 27].mergeSorted(by: >) == [42, 27, 15, 8, 3])
        #expect(["banana", "fig", "kiwi"].mergeSorted { $0.count < $1.count } == ["fig", "kiwi", "banana"])
    }

    @Test("mergeSorted is stable")
    func mergeSortedIsStable() {
        let words = ["pear", "fig", "plum", "kiwi", "yam", "date"]
        #expect(words.mergeSorted { $0.count < $1.count } == ["fig", "yam", "pear", "plum", "kiwi", "date"])

        // Many equal keys across many merges: every tag must stay in increasing order within its key
        let keys = Self.randomArray(count: 5_000, below: 10, seed: 11)
        let items = keys.enumerated().map { Tagged(key: $0.element, tag: $0.offset) }
        let sorted = items.mergeSorted { $0.key < $1.key }
        var stable = true
        for index in 1..<sorted.count {
            let previous = sorted[index - 1]
            let current = sorted[index]
            if previous.key > current.key || (previous.key == current.key && previous.tag > current.tag) {
                stable = false
            }
        }
        #expect(stable)
        #expect(sorted.count == items.count)
    }

    @Test("mergeSorted on large sorted, reversed and all-equal input")
    func mergeSortedLarge() {
        let ascending = Array(0..<100_000)
        #expect(ascending.mergeSorted() == ascending)
        #expect(Array(ascending.reversed()).mergeSorted() == ascending)
        let same = Array(repeating: 5, count: 200_000)
        #expect(same.mergeSorted() == same)
    }

    @Test("mergeSorted makes few comparisons on sorted input")
    func mergeSortedAdaptive() {
        var comparisons = 0
        let ascending = Array(0..<10_000)
        _ = ascending.mergeSorted { a, b in
            comparisons += 1
            return a < b
        }
        #expect(comparisons < 2 * ascending.count)
    }

    @Test("mergeSorted matches sorted() on random arrays", arguments: [2, 50, 1_000_000])
    func mergeSortedMatchesStandardLibrary(limit: Int) {
        var mismatches = 0
        for count in 0...300 {
            let numbers = Self.randomArray(count: count, below: limit, seed: UInt64(count * 7 + limit))
            if numbers.mergeSorted() != numbers.sorted() { mismatches += 1 }
        }
        let big = Self.randomArray(count: 50_000, below: limit, seed: 99)
        if big.mergeSorted() != big.sorted() { mismatches += 1 }
        #expect(mismatches == 0)
    }

    // MARK: quickSort

    @Test("quickSort handles empty and single-element arrays")
    func quickSortTiny() {
        var empty: [Int] = []
        empty.quickSort()
        #expect(empty == [])
        var one = [7]
        one.quickSort()
        #expect(one == [7])
        var two = [2, 1]
        two.quickSort()
        #expect(two == [1, 2])
    }

    @Test("quickSort sorts small arrays, including duplicates and negatives")
    func quickSortSmall() {
        var numbers = [5, 2, 9, 1, 5, 6]
        numbers.quickSort()
        #expect(numbers == [1, 2, 5, 5, 6, 9])
        var mixed = [3, -1, 0, -7, 3, 3]
        mixed.quickSort()
        #expect(mixed == [-7, -1, 0, 3, 3, 3])
        var words = ["pear", "fig", "apple"]
        words.quickSort()
        #expect(words == ["apple", "fig", "pear"])
    }

    @Test("quickSort follows a custom order")
    func quickSortCustomOrder() {
        var scores = [72, 38, 91, 50, 38]
        scores.quickSort(by: >)
        #expect(scores == [91, 72, 50, 38, 38])
        var words = ["banana", "fig", "kiwi"]
        words.quickSort { $0.count < $1.count }
        #expect(words == ["fig", "kiwi", "banana"])
    }

    @Test("quickSort stays fast on large sorted, reversed and all-equal input")
    func quickSortLarge() {
        let ascending = Array(0..<100_000)
        var sorted = ascending
        sorted.quickSort()
        #expect(sorted == ascending)
        var reversed = Array(ascending.reversed())
        reversed.quickSort()
        #expect(reversed == ascending)
        var same = Array(repeating: 5, count: 200_000)
        same.quickSort()
        #expect(same == Array(repeating: 5, count: 200_000))
        var twoValues = (0..<200_000).map { $0 % 2 }
        twoValues.quickSort()
        #expect(twoValues == Array(repeating: 0, count: 100_000) + Array(repeating: 1, count: 100_000))
    }

    @Test("quickSort on all-equal input needs only a linear number of comparisons")
    func quickSortAllEqualIsLinear() {
        var same = Array(repeating: 1, count: 50_000)
        var comparisons = 0
        same.quickSort { a, b in
            comparisons += 1
            return a < b
        }
        #expect(comparisons <= 2 * same.count)
    }

    @Test("quickSort matches sorted() on random arrays", arguments: [2, 50, 1_000_000])
    func quickSortMatchesStandardLibrary(limit: Int) {
        var mismatches = 0
        for count in 0...300 {
            var numbers = Self.randomArray(count: count, below: limit, seed: UInt64(count * 13 + limit))
            let expected = numbers.sorted()
            numbers.quickSort()
            if numbers != expected { mismatches += 1 }
        }
        var big = Self.randomArray(count: 50_000, below: limit, seed: 77)
        let expected = big.sorted()
        big.quickSort()
        if big != expected { mismatches += 1 }
        #expect(mismatches == 0)
    }

    @Test("quickSort keeps every element, sorting by key only")
    func quickSortKeepsElements() {
        let keys = Self.randomArray(count: 3_000, below: 20, seed: 5)
        var items = keys.enumerated().map { Tagged(key: $0.element, tag: $0.offset) }
        items.quickSort { $0.key < $1.key }
        #expect(items.map(\.key) == keys.sorted())
        #expect(items.map(\.tag).sorted() == Array(0..<3_000))
    }

    // MARK: kthSmallest

    @Test("kthSmallest is 0-based and returns nil out of range")
    func kthSmallestBasics() {
        let times = [31, 12, 47, 12, 25]
        #expect(times.kthSmallest(0) == 12)
        #expect(times.kthSmallest(1) == 12)
        #expect(times.kthSmallest(2) == 25)
        #expect(times.kthSmallest(4) == 47)
        #expect(times.kthSmallest(5) == nil)
        #expect(times.kthSmallest(-1) == nil)
        #expect([Int]().kthSmallest(0) == nil)
        #expect([9].kthSmallest(0) == 9)
        #expect(times.kthSmallest(0, by: >) == 47)
        #expect(times == [31, 12, 47, 12, 25])
    }

    @Test("kthSmallest agrees with sorting for every k", arguments: [3, 1_000])
    func kthSmallestMatchesSorting(limit: Int) {
        var mismatches = 0
        for count in 1...60 {
            let numbers = Self.randomArray(count: count, below: limit, seed: UInt64(count * 3 + limit))
            let sorted = numbers.sorted()
            for k in 0..<count where numbers.kthSmallest(k) != sorted[k] {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("kthSmallest stays fast on large sorted and all-equal input")
    func kthSmallestLarge() {
        let ascending = Array(0..<100_000)
        #expect(ascending.kthSmallest(50_000) == 50_000)
        #expect(ascending.kthSmallest(99_999) == 99_999)
        #expect(Array(ascending.reversed()).kthSmallest(0) == 0)
        let same = Array(repeating: 8, count: 200_000)
        #expect(same.kthSmallest(123_456) == 8)
        let big = Self.randomArray(count: 100_000, below: 1_000_000, seed: 3)
        #expect(big.kthSmallest(70_000) == big.sorted()[70_000])
    }
}
