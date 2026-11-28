import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BackshiftProbeSetTests {
    typealias ProbeSet = BackshiftProbeSet.ProbeSet

    /// A tiny deterministic generator, so the mixed-operation test does the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// True when every key can be reached from its home without crossing an empty slot.
    private func probePathsUnbroken(_ set: ProbeSet) -> Bool {
        let slots = set.slots
        guard slots.count == set.capacity, slots.count > 0 else { return false }
        let mask = slots.count - 1
        for (index, stored) in slots.enumerated() {
            guard let key = stored else { continue }
            var probe = key & mask
            while probe != index {
                if slots[probe] == nil { return false }
                probe = (probe + 1) & mask
            }
        }
        return true
    }

    private func made(capacity: Int, inserting keys: [Int]) -> ProbeSet {
        var set = ProbeSet(capacity: capacity)
        for key in keys {
            set.insert(key)
        }
        return set
    }

    @Test("A new set is empty")
    func startsEmpty() {
        var set = ProbeSet(capacity: 8)
        #expect(set.count == 0)
        #expect(set.capacity == 8)
        #expect(set.slots == Array(repeating: nil, count: 8))
        #expect(!set.contains(3))
        #expect(set.remove(3) == false)
    }

    @Test("Probes forward from each key's home")
    func probing() {
        let set = made(capacity: 8, inserting: [8, 16, 1, 24])
        #expect(set.slots == [8, 16, 1, 24, nil, nil, nil, nil])
        #expect(set.count == 4)
        #expect([8, 16, 1, 24].allSatisfy { set.contains($0) })
        #expect(!set.contains(32) && !set.contains(0) && !set.contains(2))
    }

    @Test("Inserting a key twice changes nothing")
    func duplicates() {
        var set = made(capacity: 8, inserting: [3, 11])
        #expect(set.insert(3) == false)
        #expect(set.insert(11) == false)
        #expect(set.insert(4) == true)
        #expect(set.count == 3)
        #expect(set.slots == [nil, nil, nil, 3, 11, 4, nil, nil])
    }

    @Test("Removing shifts later keys back into the hole")
    func backwardShift() {
        var set = made(capacity: 8, inserting: [8, 16, 1, 24])
        #expect(set.remove(16) == true)
        #expect(set.slots == [8, 1, 24, nil, nil, nil, nil, nil])
        #expect(set.count == 3)
        #expect(set.contains(24) && set.contains(1) && set.contains(8))
        #expect(!set.contains(16))
        #expect(set.remove(16) == false)

        var chain = made(capacity: 8, inserting: [8, 1, 9, 2])
        #expect(chain.remove(1) == true)
        #expect(chain.slots == [8, 9, 2, nil, nil, nil, nil, nil])
    }

    @Test("Keys that are already home stay where they are")
    func noNeedlessMoves() {
        var set = made(capacity: 8, inserting: [8, 1, 9, 2])
        #expect(set.slots == [8, 1, 9, 2, nil, nil, nil, nil])
        #expect(set.remove(8) == true)
        #expect(set.slots == [nil, 1, 9, 2, nil, nil, nil, nil])
        #expect(set.contains(1) && set.contains(9) && set.contains(2))
    }

    @Test("Runs wrap round the end of the table")
    func wrapAround() {
        var set = made(capacity: 8, inserting: [7, 15, 23])
        #expect(set.slots == [15, 23, nil, nil, nil, nil, nil, 7])
        #expect(set.remove(7) == true)
        #expect(set.slots == [23, nil, nil, nil, nil, nil, nil, 15])
        #expect(set.contains(15) && set.contains(23))
    }

    @Test("Negative keys find their home by masking")
    func negativeKeys() {
        var set = made(capacity: 8, inserting: [-1, -9, 6])
        #expect(set.slots == [-9, nil, nil, nil, nil, nil, 6, -1])
        #expect(set.remove(-1) == true)
        #expect(set.slots == [nil, nil, nil, nil, nil, nil, 6, -9])
        #expect(set.contains(-9) && !set.contains(-1))
    }

    @Test("Doubles before passing three quarters full, re-inserting in slot order")
    func growth() {
        var set = made(capacity: 4, inserting: [1, 5, 9])
        #expect(set.capacity == 4)
        #expect(set.slots == [nil, 1, 5, 9])
        #expect(set.insert(2) == true)
        #expect(set.capacity == 8)
        #expect(set.slots == [nil, 1, 9, 2, nil, 5, nil, nil])

        var tiny = ProbeSet(capacity: 1)
        tiny.insert(5)
        #expect(tiny.capacity == 2 && tiny.slots == [nil, 5])
        tiny.insert(6)
        tiny.insert(7)
        #expect(tiny.capacity == 4 && tiny.slots == [nil, 5, 6, 7])

        let six = made(capacity: 8, inserting: Array(1...6))
        #expect(six.capacity == 8)
        let seven = made(capacity: 8, inserting: Array(1...7))
        #expect(seven.capacity == 16)
    }

    @Test("Thousands of mixed operations match a Set and keep every probe path whole")
    func matchesModel() {
        var steps = Steps(seed: 24)
        var set = ProbeSet(capacity: 1)
        var model = Set<Int>()
        var mismatches = 0
        var broken = 0
        for step in 0..<20_000 {
            let key = steps.next(below: 80) - 40
            if steps.next(below: 2) == 0 {
                if set.insert(key) != model.insert(key).inserted { mismatches += 1 }
            } else {
                if set.remove(key) != (model.remove(key) != nil) { mismatches += 1 }
            }
            if set.count != model.count || set.contains(key) != model.contains(key) { mismatches += 1 }
            if step % 10 == 0 {
                let capacity = set.capacity
                let filled = set.slots.compactMap { $0 }
                if capacity == 0 || capacity & (capacity - 1) != 0 || set.count * 4 > capacity * 3 { broken += 1 }
                if filled.count != model.count || Set(filled) != model || !probePathsUnbroken(set) { broken += 1 }
            }
        }
        #expect(mismatches == 0)
        #expect(broken == 0)
    }

    @Test("Stays O(1) on average over 100,000 keys")
    func large() {
        // Multiplying by a large odd constant scatters the homes, as a real hash function would.
        // (Consecutive keys would form one run 100,000 slots long, and every removal would walk all of it.)
        let scramble = Int(bitPattern: 0x9E37_79B9_7F4A_7C15 as UInt)
        let keys = (0..<100_000).map { $0 &* scramble }
        var set = ProbeSet(capacity: 1)
        for key in keys {
            set.insert(key)
        }
        #expect(set.count == 100_000)
        #expect(set.capacity == 262_144)
        for index in stride(from: 0, to: 100_000, by: 2) {
            set.remove(keys[index])
        }
        #expect(set.count == 50_000)
        #expect(!set.contains(keys[50_000]) && set.contains(keys[50_001]) && set.contains(keys[99_999]))
        #expect(!set.contains(100_000 &* scramble))
    }

    @Test("A long shared run survives removals from its front")
    func longRun() {
        let keys = (0..<500).map { $0 * 1_024 }       // every key has home 0 in a 1,024-slot table
        var set = made(capacity: 1, inserting: keys)
        #expect(set.capacity == 1_024)
        var allFound = true
        for (index, key) in keys.enumerated() {
            set.remove(key)
            if index % 50 == 0 && !keys[(index + 1)...].allSatisfy({ set.contains($0) }) { allFound = false }
        }
        #expect(allFound)
        #expect(set.count == 0)
        #expect(set.slots.allSatisfy { $0 == nil })
    }
}
