import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DistinctVisitorSketchTests {
    /// The registers the statement's rules give, computed independently of the sketch
    private func expectedRegisters(_ ids: [Int], indexBits b: Int) -> [UInt8] {
        var registers = [UInt8](repeating: 0, count: 1 << b)
        for id in ids {
            var z = UInt64(bitPattern: Int64(id)) &+ 0x9E37_79B9_7F4A_7C15
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            let hash = z ^ (z >> 31)
            let index = Int(hash >> UInt64(64 - b))
            // Count the zeros after the index bits one bit at a time, stopping at the end of the hash
            var rank = 1
            var bit = 63 - b
            while bit >= 0 && hash & (1 << UInt64(bit)) == 0 {
                rank += 1
                bit -= 1
            }
            registers[index] = max(registers[index], UInt8(rank))
        }
        return registers
    }

    private func sketch(of ids: some Sequence<Int>, indexBits: Int) -> DistinctVisitorSketch.Sketch {
        var result = DistinctVisitorSketch.Sketch(indexBits: indexBits)
        for id in ids {
            result.add(id)
        }
        return result
    }

    @Test("The small example, register by register")
    func smallExample() {
        let small = sketch(of: 1...6, indexBits: 4)
        #expect(small.indexBits == 4)
        #expect(small.registers == [0, 1, 0, 0, 0, 0, 3, 0, 0, 4, 0, 1, 0, 0, 0, 0])
        #expect(abs(small.estimate - 16 * 0.287_682_072_451_780_9) < 1e-9)
    }

    @Test("A fresh sketch has m zero registers and estimates 0", arguments: [4, 10, 16])
    func fresh(indexBits: Int) {
        let empty = DistinctVisitorSketch.Sketch(indexBits: indexBits)
        #expect(empty.registers == [UInt8](repeating: 0, count: 1 << indexBits))
        #expect(empty.estimate == 0)
    }

    @Test("Registers match the rules exactly", arguments: [4, 7, 12, 16])
    func registersExact(indexBits: Int) {
        let ids = (0..<5_000).map { $0 &* 2_654_435_761 &- 1_000_000 }
        #expect(sketch(of: ids, indexBits: indexBits).registers == expectedRegisters(ids, indexBits: indexBits))
        let negatives = Array(-300...(-1)) + [Int.min, Int.max, 0]
        #expect(sketch(of: negatives, indexBits: indexBits).registers == expectedRegisters(negatives, indexBits: indexBits))
    }

    @Test("Estimates follow the formula, from linear counting to the raw estimate", arguments: [
        (10, 10), (100, 97), (1_000, 997), (10_000, 10_099), (100_000, 101_737),
    ])
    func estimates(count: Int, expected: Int) {
        var visitors = DistinctVisitorSketch.Sketch(indexBits: 12)
        for id in 0..<count {
            visitors.add(id)
            visitors.add(id)                      // a repeat visit changes nothing
        }
        #expect(Int(visitors.estimate.rounded()) == expected)
        #expect(abs(visitors.estimate - Double(count)) < 0.03 * Double(count) + 1)
    }

    @Test("Repeats never change the registers")
    func repeats() {
        let once = sketch(of: 0..<2_000, indexBits: 10)
        let many = sketch(of: (0..<10).flatMap { _ in 0..<2_000 }, indexBits: 10)
        #expect(once.registers == many.registers)
        #expect(once.estimate == many.estimate)
    }

    @Test("Merging gives exactly the sketch of the union, and the overlap of two days")
    func mergeAndOverlap() {
        let monday = sketch(of: 0..<60_000, indexBits: 12)
        let tuesday = sketch(of: 40_000..<100_000, indexBits: 12)
        let both = monday.merged(with: tuesday)
        #expect(both.registers == sketch(of: 0..<100_000, indexBits: 12).registers)
        #expect(Int(monday.estimate.rounded()) == 60_863)
        #expect(Int(tuesday.estimate.rounded()) == 60_895)
        #expect(Int(both.estimate.rounded()) == 101_737)
        #expect(Int(DistinctVisitorSketch.overlapEstimate(monday, tuesday).rounded()) == 20_021)
        // Merging is symmetric, and merging a sketch with itself changes nothing
        #expect(tuesday.merged(with: monday).registers == both.registers)
        #expect(monday.merged(with: monday).registers == monday.registers)
        // Disjoint days overlap by roughly nothing
        let night = sketch(of: 500_000..<540_000, indexBits: 12)
        #expect(abs(DistinctVisitorSketch.overlapEstimate(monday, night)) < 3_000)
    }

    @Test("A million visitors with 16,384 registers, within 1.5%")
    func large() {
        let visitors = sketch(of: (0..<1_000_000).lazy.map { $0 * 7 + 3 }, indexBits: 14)
        #expect(abs(visitors.estimate - 1_000_000) < 15_000)
        #expect(visitors.registers.count == 16_384)
        #expect(visitors.registers.allSatisfy { $0 > 0 }, "a million ids should reach every register")
    }
}
