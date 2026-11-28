import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FenwickSlotWalksTests {
    /// The lowest set bit, found the slow way: the smallest power of two dividing i
    private func slowLowbit(_ i: Int) -> Int {
        var bit = 1
        while i % (bit * 2) == 0 { bit *= 2 }
        return bit
    }

    @Test("Lowest set bits", arguments: [
        (1, 1), (2, 2), (3, 1), (6, 2), (7, 1), (12, 4), (20, 4), (24, 8), (64, 64), (96, 32),
        (1_000_000, 64), (1 << 59, 1 << 59), (1_000_000_000_000_000_000, 262_144),
    ])
    func lowbits(i: Int, expected: Int) {
        #expect(FenwickSlotWalks.lowbit(i) == expected)
    }

    @Test("Lowest set bits match a slow check for 1...4096")
    func lowbitsBrute() {
        for i in 1...4_096 where FenwickSlotWalks.lowbit(i) != slowLowbit(i) {
            Issue.record("lowbit(\(i)) should be \(slowLowbit(i)), got \(FenwickSlotWalks.lowbit(i))")
            return
        }
    }

    @Test("Ranges of responsibility", arguments: [
        (1, 1...1), (2, 1...2), (3, 3...3), (4, 1...4), (6, 5...6), (8, 1...8), (12, 9...12), (13, 13...13),
        (22, 21...22), (40, 33...40),
    ])
    func responsibility(i: Int, expected: ClosedRange<Int>) {
        #expect(FenwickSlotWalks.responsibility(of: i) == expected)
    }

    @Test("Query walks", arguments: [
        (13, [13, 12, 8]), (16, [16]), (7, [7, 6, 4]), (22, [22, 20, 16]), (1, [1]), (0, []),
        (255, [255, 254, 252, 248, 240, 224, 192, 128]),
    ])
    func queryWalks(i: Int, expected: [Int]) {
        #expect(FenwickSlotWalks.queryPath(to: i) == expected)
    }

    @Test("Update walks", arguments: [
        (5, 16, [5, 6, 8, 16]), (1, 16, [1, 2, 4, 8, 16]), (9, 16, [9, 10, 12, 16]), (3, 16, [3, 4, 8, 16]),
        (3, 6, [3, 4]), (6, 6, [6]), (16, 16, [16]), (1, 1, [1]), (7, 100, [7, 8, 16, 32, 64]),
    ])
    func updateWalks(i: Int, n: Int, expected: [Int]) {
        #expect(FenwickSlotWalks.updatePath(from: i, size: n) == expected)
    }

    @Test("The examples for range slots")
    func rangeExamples() {
        let first = FenwickSlotWalks.rangeSlots(from: 13, through: 15)
        #expect(first.add == [15, 14] && first.subtract == [])
        let second = FenwickSlotWalks.rangeSlots(from: 6, through: 13)
        #expect(second.add == [13, 12, 8] && second.subtract == [5, 4])
        let third = FenwickSlotWalks.rangeSlots(from: 1, through: 6)
        #expect(third.add == [6, 4] && third.subtract == [])
        let single = FenwickSlotWalks.rangeSlots(from: 8, through: 8)
        #expect(single.add == [8] && single.subtract == [7, 6, 4])
        let odd = FenwickSlotWalks.rangeSlots(from: 7, through: 7)
        #expect(odd.add == [7] && odd.subtract == [])
    }

    @Test("Query walks tile 1...i exactly, for every i up to 300")
    func queryWalksTile() {
        for i in 0...300 {
            let path = FenwickSlotWalks.queryPath(to: i)
            var covered = 0
            for slot in path.reversed() {
                let range = (slot - slowLowbit(slot) + 1)...slot
                guard range.lowerBound == covered + 1 else {
                    Issue.record("queryPath(to: \(i)) = \(path) leaves a gap or overlap at slot \(slot)")
                    return
                }
                covered = range.upperBound
            }
            #expect(covered == i, "queryPath(to: \(i)) = \(path) should cover 1...\(i)")
        }
    }

    @Test("Update walks visit exactly the slots whose ranges contain the position")
    func updateWalksContain() {
        for n in [1, 2, 7, 8, 13, 64, 100] {
            for i in 1...n {
                let expected = (1...n).filter { slot in (slot - slowLowbit(slot) + 1)...slot ~= i }
                #expect(FenwickSlotWalks.updatePath(from: i, size: n) == expected, "position \(i), size \(n)")
            }
        }
    }

    @Test("Range slots give every range sum, with nothing shared, for all ranges in 1...64")
    func rangeSlotsBrute() {
        let items = (1...64).map { ($0 * 37) % 101 - 50 }
        // A Fenwick array of the items, built the slow way from the definition
        var tree = [0]
        for slot in 1...64 {
            tree.append(items[(slot - slowLowbit(slot))..<slot].reduce(0, +))
        }
        for l in 1...64 {
            for r in l...64 {
                let (add, subtract) = FenwickSlotWalks.rangeSlots(from: l, through: r)
                let fullAdd = FenwickSlotWalks.queryPath(to: r)
                let fullSubtract = FenwickSlotWalks.queryPath(to: l - 1)
                let shared = Set(fullAdd).intersection(fullSubtract)
                #expect(add == fullAdd.filter { !shared.contains($0) }, "add for \(l)...\(r)")
                #expect(subtract == fullSubtract.filter { !shared.contains($0) }, "subtract for \(l)...\(r)")
                let sum = add.reduce(0) { $0 + tree[$1] } - subtract.reduce(0) { $0 + tree[$1] }
                #expect(sum == items[(l - 1)..<r].reduce(0, +), "sum for \(l)...\(r)")
                if add.isEmpty && subtract.isEmpty { return }
            }
        }
    }

    @Test("Indexes near 10^18 walk in O(log i) steps")
    func huge() {
        let big = 1_000_000_000_000_000_000
        let path = FenwickSlotWalks.queryPath(to: big)
        #expect(path.count == big.nonzeroBitCount)
        #expect(path.first == big)
        #expect(FenwickSlotWalks.responsibility(of: big) == (big - 262_143)...big)
        let up = FenwickSlotWalks.updatePath(from: 1, size: big)
        #expect(up.count == 60 && up.last == 1 << 59)
        let whole = FenwickSlotWalks.rangeSlots(from: big - 262_143, through: big)
        #expect(whole.add == [big] && whole.subtract == [])
        // Slot `big` covers 2^18 positions, so the 6 at the end need it minus the 16 slots of big - 6's walk
        let tail = FenwickSlotWalks.rangeSlots(from: big - 5, through: big)
        #expect(tail.add == [big])
        #expect(tail.subtract.count == 16 && tail.subtract.first == big - 6 && tail.subtract.last == big - 131_072)
    }
}
