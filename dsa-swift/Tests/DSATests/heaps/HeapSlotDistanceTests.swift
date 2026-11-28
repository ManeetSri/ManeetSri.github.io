import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The path from `index` up to the root, inclusive, worked out one parent at a time.
private func pathToRoot(_ index: Int) -> [Int] {
    var path = [index]
    while path.last! > 0 { path.append((path.last! - 1) / 2) }
    return path
}

/// The distance worked out with 1-based numbering and bits: slot i is number i + 1, its depth is one less
/// than that number's bit length, and its ancestor d levels up is the number shifted right by d.
private func bitDistance(_ first: Int, _ second: Int) -> Int {
    func bitLength(_ x: Int) -> Int { Int.bitWidth - x.leadingZeroBitCount }
    var a = first + 1
    var b = second + 1
    var steps = 0
    let gap = bitLength(a) - bitLength(b)
    if gap > 0 { a >>= gap; steps += gap }
    if gap < 0 { b >>= -gap; steps -= gap }
    while a != b {
        a >>= 1
        b >>= 1
        steps += 2
    }
    return steps
}

@Suite struct HeapSlotDistanceTests {
    @Test("The examples", arguments: [
        (3, 4, 2),
        (0, 6, 2),
        (7, 2, 4),
        (5, 5, 0),
        (1, 10, 2),
        (1_000_000_000_000_000_000, 0, 59),
    ])
    func examples(first: Int, second: Int, expected: Int) {
        #expect(HeapSlotDistance.steps(from: first, to: second) == expected)
        #expect(HeapSlotDistance.steps(from: second, to: first) == expected)
    }

    @Test("A slot and its parent, children and the root")
    func neighbours() {
        var failures: [String] = []
        for i in 0..<100 {
            if HeapSlotDistance.steps(from: i, to: 2 * i + 1) != 1 { failures.append("\(i) to its left child") }
            if HeapSlotDistance.steps(from: 2 * i + 2, to: i) != 1 { failures.append("\(i)'s right child to \(i)") }
            if HeapSlotDistance.steps(from: 2 * i + 1, to: 2 * i + 2) != 2 { failures.append("\(i)'s two children") }
            if HeapSlotDistance.steps(from: i, to: 0) != pathToRoot(i).count - 1 { failures.append("\(i) to the root") }
        }
        #expect(failures.isEmpty, "\(failures.prefix(3))")
    }

    @Test("Every pair of the first 150 slots matches walking the paths")
    func allSmallPairs() {
        var failures: [String] = []
        for a in 0..<150 {
            let pathA = pathToRoot(a)
            for b in 0..<150 {
                let pathB = pathToRoot(b)
                let common = pathA.first { pathB.contains($0) }!          // the lowest common ancestor
                let expected = pathA.firstIndex(of: common)! + pathB.firstIndex(of: common)!
                let actual = HeapSlotDistance.steps(from: a, to: b)
                if actual != expected && failures.count < 3 {
                    failures.append("\(a) to \(b): got \(actual), expected \(expected)")
                }
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Random huge slots match a bit-based calculation")
    func huge() {
        var state: UInt64 = 39
        var failures: [String] = []
        for _ in 0..<10_000 {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            let a = Int(state % 1_000_000_000_000_000_001)
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            // Sometimes a nearby slot, sometimes anywhere
            let b = state % 2 == 0 ? Int(state % 1_000_000_000_000_000_001) : max(0, a - Int(state % 1_000))
            let actual = HeapSlotDistance.steps(from: a, to: b)
            if actual != bitDistance(a, b) && failures.count < 3 {
                failures.append("\(a) to \(b): got \(actual), expected \(bitDistance(a, b))")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("The deepest slots allowed")
    func extremes() {
        let top = 1_000_000_000_000_000_000
        #expect(HeapSlotDistance.steps(from: top, to: top - 1) == bitDistance(top, top - 1))
        #expect(HeapSlotDistance.steps(from: top, to: top) == 0)
        // 2⁵⁸ − 1 is the first slot on level 58, and 2⁵⁹ − 2 the last: they only meet at the root
        #expect(HeapSlotDistance.steps(from: (1 << 58) - 1, to: (1 << 59) - 2) == 116)
    }
}
