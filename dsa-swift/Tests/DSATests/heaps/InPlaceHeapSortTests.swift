import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct InPlaceHeapSortTests {
    @Test("Sorts small arrays", arguments: [
        [Int](),
        [7],
        [2, 1],
        [1, 2],
        [5, 2, 9, 1, 6, 3],
        [3, 3, 1, 3, 1],
        [-4, 10, 0, -4, 7, 7, 2],
        [Int.max, 0, Int.min],
        [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
    ])
    func small(values: [Int]) {
        var items = values
        InPlaceHeapSort.sort(&items)
        #expect(items == values.sorted())
    }

    @Test("Agrees with sorted() on hundreds of arrays")
    func matchesSorted() {
        var mismatches = 0
        for seed in 1...300 {
            let count = seed % 40
            let values = (0..<count).map { ($0 * 7_919 + seed * 104_729) % (2 + seed % 30) - 8 }
            var items = values
            InPlaceHeapSort.sort(&items)
            if items != values.sorted() { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("100,000 values: in order, reversed, equal, organ pipe and scrambled")
    func large() {
        let ascending = Array(0..<100_000)
        var items = ascending
        InPlaceHeapSort.sort(&items)
        #expect(items == ascending)

        items = ascending.reversed()
        InPlaceHeapSort.sort(&items)
        #expect(items == ascending)

        items = Array(repeating: 4, count: 100_000)
        InPlaceHeapSort.sort(&items)
        #expect(items == Array(repeating: 4, count: 100_000))

        items = Array(0..<50_000) + Array((0..<50_000).reversed())
        InPlaceHeapSort.sort(&items)
        #expect(items == (0..<100_000).map { $0 / 2 })

        items = (0..<100_000).map { ($0 * 7_919) % 100_000 }
        InPlaceHeapSort.sort(&items)
        #expect(items == ascending)
    }
}
