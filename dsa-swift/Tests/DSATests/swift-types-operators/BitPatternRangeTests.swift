import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BitPatternRangeTests {
    @Test("Matches Swift's 8-bit types")
    func eightBits() {
        #expect(BitPatternRange.signedMin(patterns: 256) == Int(Int8.min))
        #expect(BitPatternRange.signedMax(patterns: 256) == Int(Int8.max))
        #expect(BitPatternRange.unsignedMax(patterns: 256) == Int(UInt8.max))
    }

    @Test("Matches Swift's 16-bit types")
    func sixteenBits() {
        #expect(BitPatternRange.signedMin(patterns: 65_536) == Int(Int16.min))
        #expect(BitPatternRange.signedMax(patterns: 65_536) == Int(Int16.max))
        #expect(BitPatternRange.unsignedMax(patterns: 65_536) == Int(UInt16.max))
    }

    @Test("Matches Swift's 32-bit types")
    func thirtyTwoBits() {
        let patterns = 4_294_967_296
        #expect(BitPatternRange.signedMin(patterns: patterns) == Int(Int32.min))
        #expect(BitPatternRange.signedMax(patterns: patterns) == Int(Int32.max))
        #expect(BitPatternRange.unsignedMax(patterns: patterns) == Int(UInt32.max))
    }

    @Test("Works for sizes Swift has no type for", arguments: [
        (2, -1, 0, 1),
        (4, -2, 1, 3),
        (8, -4, 3, 7),
        (32, -16, 15, 31),
        (1_024, -512, 511, 1_023),
    ])
    func otherSizes(patterns: Int, minimum: Int, maximum: Int, unsignedMaximum: Int) {
        #expect(BitPatternRange.signedMin(patterns: patterns) == minimum)
        #expect(BitPatternRange.signedMax(patterns: patterns) == maximum)
        #expect(BitPatternRange.unsignedMax(patterns: patterns) == unsignedMaximum)
    }

    @Test("The signed maximum is one less than the size of the minimum", arguments: [2, 16, 256, 65_536, 1_048_576])
    func asymmetry(patterns: Int) {
        let minimum = BitPatternRange.signedMin(patterns: patterns)
        #expect(minimum < 0)
        #expect(BitPatternRange.signedMax(patterns: patterns) == -minimum - 1)
    }

    @Test("Handles 62 bits, the largest allowed")
    func largest() {
        let patterns = 4_611_686_018_427_387_904
        #expect(BitPatternRange.signedMin(patterns: patterns) == -2_305_843_009_213_693_952)
        #expect(BitPatternRange.signedMax(patterns: patterns) == 2_305_843_009_213_693_951)
        #expect(BitPatternRange.unsignedMax(patterns: patterns) == 4_611_686_018_427_387_903)
    }
}
