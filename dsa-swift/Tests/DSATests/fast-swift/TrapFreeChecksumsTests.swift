import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct ChecksumRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TrapFreeChecksumsTests {
    @Test("FNV-1a hashes", arguments: [
        ("", 14_695_981_039_346_656_037 as UInt64),
        ("a", 12_638_187_200_555_641_996),
        ("swift", 11_823_696_842_872_234_712),
        ("hello world", 8_618_312_879_776_256_743),
        ("café", 5_253_592_154_431_032_713),
    ])
    func hashes(text: String, expected: UInt64) {
        #expect(TrapFreeChecksums.fnv1a(text) == expected)
    }

    @Test("The sum examples")
    func sums() {
        #expect(TrapFreeChecksums.wrappingSum([Int.max, 1]) == Int.min)
        #expect(TrapFreeChecksums.wrappingSum([]) == 0)
        #expect(TrapFreeChecksums.wrappingSum([Int.min, -1]) == Int.max)
        #expect(TrapFreeChecksums.wrappingSum([5, -7, 2]) == 0)
        #expect(TrapFreeChecksums.checkedSum([Int.max, 1]) == nil)
        #expect(TrapFreeChecksums.checkedSum([Int.max, -1, 1]) == Int.max)
        #expect(TrapFreeChecksums.checkedSum([Int.max, 1, -1]) == nil)
        #expect(TrapFreeChecksums.checkedSum([Int.min, -1]) == nil)
        #expect(TrapFreeChecksums.checkedSum([Int.min, Int.max]) == -1)
        #expect(TrapFreeChecksums.checkedSum([]) == 0)
    }

    @Test("The product examples")
    func products() {
        #expect(TrapFreeChecksums.checkedProduct([3, -4, 5]) == -60)
        #expect(TrapFreeChecksums.checkedProduct([1 << 32, 1 << 31]) == nil)
        #expect(TrapFreeChecksums.checkedProduct([1 << 31, 1 << 31]) == 1 << 62)
        #expect(TrapFreeChecksums.checkedProduct([1 << 31, 1 << 31, 0]) == 0)
        #expect(TrapFreeChecksums.checkedProduct([1 << 32, 1 << 32, 0]) == nil)
        #expect(TrapFreeChecksums.checkedProduct([Int.min, -1]) == nil)
        #expect(TrapFreeChecksums.checkedProduct([Int.min, 1]) == Int.min)
        #expect(TrapFreeChecksums.checkedProduct([]) == 1)
        #expect(TrapFreeChecksums.checkedProduct([0, Int.max, Int.max]) == 0)
    }

    @Test("Midpoints, including the extremes", arguments: [
        (3, 8, 5), (8, 3, 5), (-3, 8, 2), (-3, -8, -6), (7, 7, 7), (-1, 0, -1), (0, 1, 0),
        (Int.max, Int.max - 2, Int.max - 1), (Int.min, Int.max, -1), (Int.max, Int.max, Int.max),
        (Int.min, Int.min, Int.min), (Int.min, Int.min + 1, Int.min),
    ])
    func midpoints(a: Int, b: Int, expected: Int) {
        #expect(TrapFreeChecksums.midpoint(a, b) == expected)
    }

    @Test("Random extreme values match careful references")
    func randomExtremes() {
        var random = ChecksumRandom(seed: 68)
        let specials = [Int.max, Int.min, Int.max - 1, Int.min + 1, 0, 1, -1, 1 << 62, -(1 << 62)]
        for _ in 0..<2_000 {
            let count = Int.random(in: 0...6, using: &random)
            let values = (0..<count).map { _ in
                Bool.random(using: &random) ? specials.randomElement(using: &random)! : Int(truncatingIfNeeded: random.next())
            }
            // References built only from operators that can't trap
            var total = 0
            var sumOverflowed = false
            var product = 1
            var productOverflowed = false
            for value in values {
                let sum = total.addingReportingOverflow(value)
                sumOverflowed = sumOverflowed || sum.overflow
                total = sum.partialValue
                let next = product.multipliedReportingOverflow(by: value)
                productOverflowed = productOverflowed || next.overflow
                product = next.partialValue
            }
            let wrapped = TrapFreeChecksums.wrappingSum(values)
            let checked = TrapFreeChecksums.checkedSum(values)
            let multiplied = TrapFreeChecksums.checkedProduct(values)
            #expect(wrapped == total, "\(values)")
            #expect(checked == (sumOverflowed ? nil : total), "\(values)")
            #expect(multiplied == (productOverflowed ? nil : product), "\(values)")
            var allRight = wrapped == total && checked == (sumOverflowed ? nil : total) && multiplied == (productOverflowed ? nil : product)
            if values.count >= 2 {
                let (a, b) = (values[0], values[1])
                let middle = TrapFreeChecksums.midpoint(a, b)
                #expect(middle == (a >> 1) + (b >> 1) + (a & b & 1), "midpoint(\(a), \(b))")
                allRight = allRight && middle == (a >> 1) + (b >> 1) + (a & b & 1)
            }
            if !allRight { return }               // one failing case is enough to report
        }
    }

    @Test("A million values, and a long text")
    func large() {
        var random = ChecksumRandom(seed: 1_000_000)
        let values = (0..<1_000_000).map { _ in Int(truncatingIfNeeded: random.next()) }
        let wrapped = values.reduce(0, &+)
        #expect(TrapFreeChecksums.wrappingSum(values) == wrapped)
        #expect(TrapFreeChecksums.checkedSum(values) == nil, "random 64-bit values overflow almost at once")
        let small = (0..<1_000_000).map { $0 % 2_001 - 1_000 }
        #expect(TrapFreeChecksums.checkedSum(small) == small.reduce(0, +))
        let text = String(repeating: "the quick brown fox ", count: 50_000)
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in text.utf8 {
            hash = (hash ^ UInt64(byte)) &* 1_099_511_628_211
        }
        #expect(TrapFreeChecksums.fnv1a(text) == hash)
    }
}
