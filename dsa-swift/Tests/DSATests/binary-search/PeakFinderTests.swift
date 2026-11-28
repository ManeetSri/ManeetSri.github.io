import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PeakFinderTests {
    /// True when `index` is a real position whose value beats each neighbour it has.
    private func isPeak(_ index: Int, in heights: [Int]) -> Bool {
        guard heights.indices.contains(index) else { return false }
        let beatsLeft = index == 0 || heights[index - 1] < heights[index]
        let beatsRight = index == heights.count - 1 || heights[index + 1] < heights[index]
        return beatsLeft && beatsRight
    }

    @Test("Returns a peak", arguments: [
        [1, 3, 2],
        [2, 9, 4, 6, 1],
        [5, 1, 4, 2, 8, 7],
        [1, 2, 3, 4, 5],
        [5, 4, 3, 2, 1],
        [3, 1, 3, 1, 3],
        [-7, -2, -9],
    ])
    func findsAPeak(heights: [Int]) {
        let index = PeakFinder.peakIndex(in: heights)
        #expect(isPeak(index, in: heights), "index \(index) in \(heights)")
    }

    @Test("One and two values")
    func tiny() {
        #expect(PeakFinder.peakIndex(in: [42]) == 0)
        #expect(PeakFinder.peakIndex(in: [1, 2]) == 1)
        #expect(PeakFinder.peakIndex(in: [2, 1]) == 0)
    }

    @Test("A mountain has exactly one peak")
    func mountain() {
        #expect(PeakFinder.peakIndex(in: [0, 2, 5, 9, 7, 3]) == 3)
        #expect(PeakFinder.peakIndex(in: [1, 10, 9, 8, 7, 6, 5]) == 1)
    }

    @Test("Handles the extremes of Int")
    func extremes() {
        #expect(PeakFinder.peakIndex(in: [Int.min, Int.max, Int.min]) == 1)
        #expect(PeakFinder.peakIndex(in: [Int.min, Int.max]) == 1)
    }

    @Test("Always returns a peak on many small arrays")
    func manySmall() {
        var firstFailure: String? = nil
        for seed in 1..<500 {
            let count = seed % 9 + 1
            // Neighbours always differ: each step goes up or down by 1 to 3
            var heights = [seed % 7]
            var state = seed
            while heights.count < count {
                state = (state * 1_103 + 12_345) % 65_536
                let step = state % 3 + 1
                heights.append(heights.last! + (state % 2 == 0 ? step : -step))
            }
            let index = PeakFinder.peakIndex(in: heights)
            if !isPeak(index, in: heights) {
                firstFailure = firstFailure ?? "index \(index) in \(heights)"
            }
        }
        #expect(firstFailure == nil, "the first input where the answer isn't a peak")
    }

    @Test("A million heights, with the summit in 2,000 places")
    func large() {
        let n = 1_000_000
        // With the summit at p, heights[i] is i up to p and -i after it: one peak, at p.
        // Moving the summit on by one changes one element.
        var heights = (0..<n).map { $0 == 0 ? 0 : -$0 }
        var wrong = 0
        for p in 0..<n {
            if p > 0 {
                heights[p] = p
            }
            if p % 500 == 0 && PeakFinder.peakIndex(in: heights) != p {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
