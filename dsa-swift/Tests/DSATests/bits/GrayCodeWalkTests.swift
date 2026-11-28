import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GrayCodeWalkTests {
    @Test("Sequence examples")
    func sequenceExamples() {
        #expect(GrayCodeWalk.sequence(width: 0) == [0])
        #expect(GrayCodeWalk.sequence(width: 1) == [0, 1])
        #expect(GrayCodeWalk.sequence(width: 2) == [0, 1, 3, 2])
        #expect(GrayCodeWalk.sequence(width: 3) == [0, 1, 3, 2, 6, 7, 5, 4])
    }

    @Test("Every width: each code once, neighbours one bit apart, wrapping around", arguments: [4, 9, 16, 20])
    func sequenceProperties(width: Int) throws {
        let codes = GrayCodeWalk.sequence(width: width)
        try #require(codes.count == 1 << width)
        #expect(Set(codes).count == codes.count)
        #expect(codes.allSatisfy { (0..<(1 << width)).contains($0) })
        let oneBitSteps = zip(codes, codes.dropFirst()).allSatisfy { ($0 ^ $1).nonzeroBitCount == 1 }
        #expect(oneBitSteps)
        #expect((codes.last! ^ codes.first!).nonzeroBitCount == 1)
    }

    @Test("Decoding examples", arguments: [(0, 0), (1, 1), (3, 2), (2, 3), (6, 4), (4, 7), (0b1011, 13)])
    func stepExamples(code: Int, expected: Int) {
        #expect(GrayCodeWalk.step(ofCode: code) == expected)
    }

    @Test("Decoding undoes encoding for every 16-bit step")
    func roundTrip() {
        let wrong = (0..<(1 << 16)).filter { GrayCodeWalk.step(ofCode: $0 ^ ($0 >> 1)) != $0 }
        #expect(wrong.isEmpty, "wrong for steps \(Array(wrong.prefix(5)))")
    }

    @Test("Decoding large codes")
    func stepLarge() {
        #expect(GrayCodeWalk.step(ofCode: 1 << 61) == (1 << 62) - 1)
        #expect(GrayCodeWalk.step(ofCode: (1 << 62) - 1) == 3_074_457_345_618_258_602)
        let i = 4_000_000_000_000_000_000
        #expect(GrayCodeWalk.step(ofCode: i ^ (i >> 1)) == i)
    }

    @Test("Subset totals examples")
    func totalsExamples() {
        #expect(GrayCodeWalk.subsetTotals([3, 1, 4]) == [0, 3, 4, 1, 5, 8, 7, 4])
        #expect(GrayCodeWalk.subsetTotals([]) == [0])
        #expect(GrayCodeWalk.subsetTotals([7]) == [0, 7])
        #expect(GrayCodeWalk.subsetTotals([-2, 5]) == [0, -2, 3, 5])
    }

    @Test("The lesson's prices: three subsets add up to 7")
    func lessonPrices() {
        let totals = GrayCodeWalk.subsetTotals([3, 1, 4, 2, 5])
        #expect(totals.count == 32)
        #expect(totals.filter { $0 == 7 }.count == 3)
    }

    @Test("Totals match adding up each subset from scratch")
    func totalsMatchScratch() {
        let prices = [12, -7, 30, 1, -1_000_000_000, 64, 5, 999_999_999, -3, 8, 17, 2]
        let totals = GrayCodeWalk.subsetTotals(prices)
        #expect(totals.count == 1 << prices.count)
        var wrong: [Int] = []
        for i in 0..<totals.count {
            let gray = i ^ (i >> 1)
            var expected = 0
            for j in 0..<prices.count where gray & (1 << j) != 0 {
                expected += prices[j]
            }
            if totals[i] != expected {
                wrong.append(i)
            }
        }
        #expect(wrong.isEmpty, "wrong at steps \(Array(wrong.prefix(5)))")
    }

    @Test("Twenty prices: a million subsets")
    func totalsLarge() throws {
        let prices = Array(1...20)
        let totals = GrayCodeWalk.subsetTotals(prices)
        try #require(totals.count == 1 << 20)
        #expect(totals[(1 << 20) - 1] == 20)              // the last code is 1 << 19: just the last price
        #expect(totals.max() == 210)
        #expect(totals.filter { $0 == 210 }.count == 1)
    }
}
