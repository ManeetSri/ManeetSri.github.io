import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct LedgerRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct VersionedLedgerSumsTests {
    /// The smallest index whose running total reaches `target`, found by scanning
    private func scanFirstReaching(_ balances: [Int], _ target: Int) -> Int? {
        var running = 0
        for (index, balance) in balances.enumerated() {
            running += balance
            if running >= target { return index }
        }
        return nil
    }

    @Test("The examples")
    func examples() {
        var ledger = VersionedLedgerSums.Ledger([5, 3, 7, 9])
        #expect(ledger.versionCount == 1)
        #expect(ledger.deposit(2, into: 1, basedOn: 0) == 1)
        #expect(ledger.deposit(-5, into: 0, basedOn: 1) == 2)
        #expect(ledger.deposit(10, into: 3, basedOn: 0) == 3)
        #expect(ledger.total(from: 0, through: 3, in: 0) == 24)
        #expect(ledger.total(from: 0, through: 3, in: 1) == 26)
        #expect(ledger.total(from: 1, through: 2, in: 2) == 12)
        #expect(ledger.total(from: 0, through: 3, in: 3) == 34)
        #expect(ledger.firstReaching(8, in: 0) == 1)
        #expect(ledger.firstReaching(8, in: 2) == 2)
        #expect(ledger.firstReaching(30, in: 3) == 3)
        #expect(ledger.firstReaching(30, in: 0) == nil)
        #expect(ledger.versionCount == 4)
    }

    @Test("One member, zero targets and empty balances")
    func edges() {
        var ledger = VersionedLedgerSums.Ledger([0])
        #expect(ledger.total(from: 0, through: 0, in: 0) == 0)
        #expect(ledger.firstReaching(0, in: 0) == 0)
        #expect(ledger.firstReaching(1, in: 0) == nil)
        #expect(ledger.deposit(7, into: 0, basedOn: 0) == 1)
        #expect(ledger.firstReaching(7, in: 1) == 0)
        #expect(ledger.firstReaching(8, in: 1) == nil)
        #expect(ledger.total(from: 0, through: 0, in: 0) == 0)

        let zeros = VersionedLedgerSums.Ledger([0, 0, 4, 0, 0])
        #expect(zeros.firstReaching(1, in: 0) == 2)
        #expect(zeros.firstReaching(4, in: 0) == 2)
        #expect(zeros.firstReaching(-3, in: 0) == 0)
    }

    @Test("Old versions never change, even after branching from them many times")
    func versionsSurvive() {
        var ledger = VersionedLedgerSums.Ledger([1, 1, 1, 1, 1, 1, 1, 1])
        for member in 0..<8 {
            _ = ledger.deposit(10, into: member, basedOn: 0)    // eight branches from version 0
        }
        #expect(ledger.total(from: 0, through: 7, in: 0) == 8)
        for version in 1...8 {
            #expect(ledger.total(from: 0, through: 7, in: version) == 18)
            #expect(ledger.total(from: version - 1, through: version - 1, in: version) == 11)
            #expect(ledger.firstReaching(11, in: version) == version - 1)
        }
    }

    @Test("Random deposits, withdrawals and branches match copying every version")
    func matchesCopies() {
        var random = LedgerRandom(seed: 60)
        for _ in 0..<20 {
            let n = Int.random(in: 1...12, using: &random)
            var versions = [(0..<n).map { _ in Int.random(in: 0...20, using: &random) }]
            var ledger = VersionedLedgerSums.Ledger(versions[0])
            for _ in 0..<60 {
                if Bool.random(using: &random) {
                    let base = Int.random(in: 0..<versions.count, using: &random)
                    let index = Int.random(in: 0..<n, using: &random)
                    let amount = Int.random(in: -versions[base][index]...15, using: &random)
                    var next = versions[base]
                    next[index] += amount
                    versions.append(next)
                    let version = ledger.deposit(amount, into: index, basedOn: base)
                    #expect(version == versions.count - 1)
                    if version != versions.count - 1 { return }
                } else {
                    let version = Int.random(in: 0..<versions.count, using: &random)
                    let left = Int.random(in: 0..<n, using: &random)
                    let right = Int.random(in: left..<n, using: &random)
                    let balances = versions[version]
                    #expect(ledger.total(from: left, through: right, in: version) == balances[left...right].reduce(0, +))
                    let target = Int.random(in: -2...(balances.reduce(0, +) + 3), using: &random)
                    #expect(ledger.firstReaching(target, in: version) == scanFirstReaching(balances, target))
                }
            }
            #expect(ledger.versionCount == versions.count)
        }
    }

    @Test("100,000 deposits and queries on 100,000 members")
    func large() {
        var random = LedgerRandom(seed: 100_000)
        let n = 100_000
        let initial = (0..<n).map { _ in Int.random(in: 0...1_000_000, using: &random) }
        var ledger = VersionedLedgerSums.Ledger(initial)
        // Each version's parent and change, so a few versions can be rebuilt to check against
        var parent = [-1]
        var change = [(index: 0, amount: 0)]
        for _ in 0..<100_000 {
            let base = Bool.random(using: &random) ? parent.count - 1 : Int.random(in: 0..<parent.count, using: &random)
            let index = Int.random(in: 0..<n, using: &random)
            let amount = Int.random(in: 0...1_000_000, using: &random)
            _ = ledger.deposit(amount, into: index, basedOn: base)
            parent.append(base)
            change.append((index, amount))
        }
        #expect(ledger.versionCount == parent.count)
        var checksum = 0
        for _ in 0..<100_000 {
            let version = Int.random(in: 0..<parent.count, using: &random)
            let left = Int.random(in: 0..<n, using: &random)
            let right = Int.random(in: left..<n, using: &random)
            checksum &+= ledger.total(from: left, through: right, in: version)
            checksum &+= ledger.firstReaching(Int.random(in: 0...50_000_000_000, using: &random), in: version) ?? -1
        }
        #expect(checksum != 0)
        // Rebuild a few versions from their chain of changes and compare
        for version in [0, 1, 777, 50_000, parent.count - 1] {
            var balances = initial
            var v = version
            while v > 0 {
                balances[change[v].index] += change[v].amount
                v = parent[v]
            }
            #expect(ledger.total(from: 0, through: n - 1, in: version) == balances.reduce(0, +), "version \(version)")
            #expect(ledger.total(from: 12_345, through: 67_890, in: version) == balances[12_345...67_890].reduce(0, +))
            let target = balances.reduce(0, +) / 3
            #expect(ledger.firstReaching(target, in: version) == scanFirstReaching(balances, target), "version \(version)")
        }
    }
}
