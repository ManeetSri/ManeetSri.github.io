import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Bank = MeldableHeapBank.HeapBank

private struct Dice {
    var state: UInt64
    mutating func roll(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int(state >> 33) % bound
    }
}

@Suite struct MeldableHeapBankTests {
    @Test("The examples")
    func examples() {
        var bank = Bank(count: 3)
        for value in [5, 1, 9] { bank.push(value, onto: 0) }
        for value in [4, 7] { bank.push(value, onto: 1) }
        #expect(bank.min(of: 0) == 1)
        #expect(bank.min(of: 1) == 4)
        bank.meld(0, into: 1)
        #expect(bank.size(of: 1) == 5)
        #expect(bank.size(of: 0) == 0)
        #expect(bank.min(of: 1) == 1)
        #expect(bank.popMin(from: 1) == 1)
        #expect(bank.popMin(from: 1) == 4)
        #expect(bank.popMin(from: 1) == 5)
        #expect(bank.popMin(from: 0) == nil)
        #expect(bank.min(of: 2) == nil)
        bank.meld(1, into: 1)
        #expect(bank.size(of: 1) == 2)
        #expect(bank.popMin(from: 1) == 7)
        #expect(bank.popMin(from: 1) == 9)
        #expect(bank.popMin(from: 1) == nil)
    }

    @Test("Melding empty heaps, and into empty heaps")
    func emptyMelds() {
        var bank = Bank(count: 3)
        bank.meld(0, into: 1)
        #expect(bank.size(of: 1) == 0 && bank.min(of: 1) == nil)
        bank.push(3, onto: 2)
        bank.meld(2, into: 0)
        #expect(bank.min(of: 0) == 3 && bank.size(of: 2) == 0)
        bank.meld(1, into: 0)
        #expect(bank.size(of: 0) == 1)
        bank.push(1, onto: 2)                    // a melded-away heap can be used again
        #expect(bank.popMin(from: 2) == 1)
        #expect(bank.popMin(from: 0) == 3)
    }

    @Test("Duplicates and extremes")
    func duplicates() {
        var bank = Bank(count: 2)
        for value in [2, Int.max, 2, Int.min, 2] { bank.push(value, onto: 0) }
        bank.push(Int.min, onto: 1)
        bank.meld(1, into: 0)
        var popped: [Int] = []
        while let value = bank.popMin(from: 0) { popped.append(value) }
        #expect(popped == [Int.min, Int.min, 2, 2, 2, Int.max])
    }

    @Test("Random operations match plain arrays")
    func randomOperations() {
        var dice = Dice(state: 44)
        var failures: [String] = []
        for round in 0..<40 {
            let count = 1 + round % 6
            var bank = Bank(count: count)
            var reference = Array(repeating: [Int](), count: count)
            for _ in 0..<400 {
                let heap = dice.roll(count)
                switch dice.roll(5) {
                case 0, 1:
                    let value = dice.roll(round % 2 == 0 ? 8 : 1_000)
                    bank.push(value, onto: heap)
                    reference[heap].append(value)
                case 2:
                    let expected = reference[heap].min()
                    if let expected { reference[heap].remove(at: reference[heap].firstIndex(of: expected)!) }
                    let actual = bank.popMin(from: heap)
                    if actual != expected { failures.append("popMin(from: \(heap)) gave \(String(describing: actual)), expected \(String(describing: expected))") }
                case 3:
                    let target = dice.roll(count)
                    bank.meld(heap, into: target)
                    if heap != target {
                        reference[target] += reference[heap]
                        reference[heap] = []
                    }
                default:
                    break
                }
                for h in 0..<count where bank.size(of: h) != reference[h].count || bank.min(of: h) != reference[h].min() {
                    failures.append("heap \(h): size \(bank.size(of: h)), min \(String(describing: bank.min(of: h))); expected \(reference[h].count), \(String(describing: reference[h].min()))")
                }
                if failures.count >= 3 { break }
            }
            if failures.count >= 3 { break }
        }
        #expect(failures.isEmpty, "\(failures.prefix(3))")
    }

    @Test("100,000 heaps melded one after another, then drained")
    func chainOfMelds() {
        let n = 100_000
        var bank = Bank(count: n)
        for heap in 0..<n { bank.push((heap * 7_919) % n, onto: heap) }
        for heap in 0..<(n - 1) {
            bank.meld(heap, into: heap + 1)           // the big heap pours into a single value each time
        }
        #expect(bank.size(of: n - 1) == n)
        #expect(bank.size(of: 0) == 0)
        var wrong = 0
        for expected in 0..<n where bank.popMin(from: n - 1) != expected {
            wrong += 1
        }
        #expect(wrong == 0)
        #expect(bank.popMin(from: n - 1) == nil)
    }

    @Test("100,000 values pushed in decreasing order onto one heap, then a tournament of melds")
    func decreasingAndTournament() {
        let n = 100_000
        var single = Bank(count: 1)
        for value in stride(from: n, to: 0, by: -1) { single.push(value, onto: 0) }
        var wrong = 0
        for expected in 1...1_000 where single.popMin(from: 0) != expected { wrong += 1 }
        #expect(wrong == 0)
        #expect(single.size(of: 0) == n - 1_000)

        let heaps = 1 << 15
        var bank = Bank(count: heaps)
        for value in 0..<(2 * heaps) { bank.push(value, onto: (value * 40_503) % heaps) }
        var step = 1
        while step < heaps {                            // meld pairs, then pairs of pairs, …
            for heap in stride(from: 0, to: heaps, by: 2 * step) {
                bank.meld(heap + step, into: heap)
            }
            step *= 2
        }
        #expect(bank.size(of: 0) == 2 * heaps)
        for expected in 0..<(2 * heaps) where bank.popMin(from: 0) != expected { wrong += 1 }
        #expect(wrong == 0)
    }
}
