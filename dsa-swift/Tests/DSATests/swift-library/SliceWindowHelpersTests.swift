import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SliceWindowHelpersTests {
    @Test("Windows of an array", arguments: [
        ([4, 7, 5, 9, 12, 11], 3, [[4, 7, 5], [7, 5, 9], [5, 9, 12], [9, 12, 11]]),
        ([4, 7, 5], 1, [[4], [7], [5]]),
        ([4, 7, 5], 3, [[4, 7, 5]]),
        ([4, 7, 5], 4, []),
        ([], 1, []),
        ([8], 1, [[8]]),
    ] as [([Int], Int, [[Int]])])
    func windowsOfArray(items: [Int], count: Int, expected: [[Int]]) {
        #expect(SliceWindowHelpers.windows(of: items, count: count).map(Array.init) == expected)
    }

    @Test("Chunks of an array", arguments: [
        ([4, 7, 5, 9, 12, 11], 4, [[4, 7, 5, 9], [12, 11]]),
        ([4, 7, 5, 9, 12, 11], 2, [[4, 7], [5, 9], [12, 11]]),
        ([4, 7, 5], 1, [[4], [7], [5]]),
        ([4, 7, 5], 10, [[4, 7, 5]]),
        ([], 3, []),
    ] as [([Int], Int, [[Int]])])
    func chunksOfArray(items: [Int], count: Int, expected: [[Int]]) {
        #expect(SliceWindowHelpers.chunks(of: items, count: count).map(Array.init) == expected)
    }

    @Test("Adjacent pairs of an array", arguments: [
        ([150, 152, 149, 160], [[150, 152], [152, 149], [149, 160]]),
        ([1, 2], [[1, 2]]),
        ([1], []),
        ([], []),
    ] as [([Int], [[Int]])])
    func pairsOfArray(items: [Int], expected: [[Int]]) {
        #expect(SliceWindowHelpers.adjacentPairs(of: items).map { [$0.0, $0.1] } == expected)
    }

    @Test("Strings: windows and chunks are Substrings")
    func strings() {
        #expect(SliceWindowHelpers.windows(of: "swift", count: 2).map(String.init) == ["sw", "wi", "if", "ft"])
        #expect(SliceWindowHelpers.chunks(of: "abcdefg", count: 3).map(String.init) == ["abc", "def", "g"])
        #expect(SliceWindowHelpers.windows(of: "café", count: 4).map(String.init) == ["café"])
        #expect(SliceWindowHelpers.windows(of: "", count: 1).isEmpty)
        let pairs = SliceWindowHelpers.adjacentPairs(of: "abc").map { "\($0.0)\($0.1)" }
        #expect(pairs == ["ab", "bc"])
    }

    @Test("Slices keep the parent's indexes")
    func slicesKeepIndexes() {
        let scores = [10, 20, 30, 40, 50, 60, 70]
        let tail = scores[2...]
        let windows = SliceWindowHelpers.windows(of: tail, count: 2)
        #expect(windows.map(\.startIndex) == [2, 3, 4, 5])
        #expect(windows.map(Array.init) == [[30, 40], [40, 50], [50, 60], [60, 70]])
        let chunks = SliceWindowHelpers.chunks(of: tail, count: 2)
        #expect(chunks.map(\.startIndex) == [2, 4, 6])
        #expect(chunks.map(Array.init) == [[30, 40], [50, 60], [70]])
        #expect(SliceWindowHelpers.adjacentPairs(of: tail).map { $0.0 + $0.1 } == [70, 90, 110, 130])
        // Windows of an array are slices of it too, not copies starting at 0
        #expect(SliceWindowHelpers.windows(of: scores, count: 3).map(\.startIndex) == [0, 1, 2, 3, 4])
    }

    @Test("Works on a collection whose indexes aren't Ints")
    func setIndexes() {
        let squares = (1...6).map { $0 * $0 }
        let set = Set(squares)
        let windows = SliceWindowHelpers.windows(of: set, count: 2)
        #expect(windows.count == 5)
        #expect(windows.allSatisfy { $0.count == 2 })
        let chunks = SliceWindowHelpers.chunks(of: set, count: 4)
        #expect(chunks.map(\.count) == [4, 2])
        #expect(Set(chunks.flatMap { $0 }) == set)
        #expect(SliceWindowHelpers.adjacentPairs(of: set).count == 5)
    }

    @Test("50,000 elements")
    func large() {
        let items = Array(0..<50_000)
        let windows = SliceWindowHelpers.windows(of: items, count: 500)
        #expect(windows.count == 49_501)
        #expect(windows.first.map(Array.init) == Array(0..<500))
        #expect(windows.last.map(Array.init) == Array(49_500..<50_000))
        let chunks = SliceWindowHelpers.chunks(of: items, count: 7)
        #expect(chunks.count == 7_143)
        #expect(chunks.last.map(Array.init) == [49_994, 49_995, 49_996, 49_997, 49_998, 49_999])
        let pairs = SliceWindowHelpers.adjacentPairs(of: items)
        #expect(pairs.count == 49_999)
        #expect(pairs.allSatisfy { $0.1 == $0.0 + 1 })
    }
}
