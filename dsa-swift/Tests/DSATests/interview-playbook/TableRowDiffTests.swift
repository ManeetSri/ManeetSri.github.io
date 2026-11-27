import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run diffs the same lists
private struct RowDiffRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TableRowDiffTests {
    /// The textbook LCS table, one row at a time
    private func lcsLength(_ a: [String], _ b: [String]) -> Int {
        var previous = Array(repeating: 0, count: b.count + 1)
        for x in a {
            var current = Array(repeating: 0, count: b.count + 1)
            for (j, y) in b.enumerated() {
                current[j + 1] = x == y ? previous[j] + 1 : max(previous[j + 1], current[j])
            }
            previous = current
        }
        return previous[b.count]
    }

    /// With unique ids, the LCS is the longest increasing run of old positions read in new order
    private func lisLength(_ old: [String], _ new: [String]) -> Int {
        let position = Dictionary(uniqueKeysWithValues: old.enumerated().map { ($1, $0) })
        var tails: [Int] = []
        for id in new {
            guard let value = position[id] else { continue }
            var low = 0, high = tails.count
            while low < high {
                let mid = (low + high) / 2
                if tails[mid] < value { low = mid + 1 } else { high = mid }
            }
            if low == tails.count { tails.append(value) } else { tails[low] = value }
        }
        return tails.count
    }

    /// Everything wrong with `changes` as a diff of old → new with the fewest changes, or [] if it's right
    private func issues(_ changes: TableRowDiff.Changes, old: [String], new: [String], longestKept: Int) -> [String] {
        var found: [String] = []
        let ascending = { (indexes: [Int], count: Int) in
            zip(indexes, indexes.dropFirst()).allSatisfy { $0 < $1 } && indexes.allSatisfy { (0..<count).contains($0) }
        }
        if !ascending(changes.deletions, old.count) { found.append("deletions must be valid old indexes in increasing order") }
        if !ascending(changes.insertions, new.count) { found.append("insertions must be valid new indexes in increasing order") }
        guard found.isEmpty else { return found }
        let deleted = Set(changes.deletions), inserted = Set(changes.insertions)
        let keptOld = old.indices.filter { !deleted.contains($0) }.map { old[$0] }
        let keptNew = new.indices.filter { !inserted.contains($0) }.map { new[$0] }
        if keptOld != keptNew { found.append("the rows left after deleting don't match the rows left after removing insertions") }
        if keptOld.count != longestKept { found.append("keeps \(keptOld.count) rows, but \(longestKept) can stay") }
        return found
    }

    @Test("Examples with a single right answer", arguments: [
        (["a", "b", "c", "d"], ["a", "c", "d", "e"], [1], [3]),
        ([], ["x", "y"], [], [0, 1]),
        (["x", "y"], [], [0, 1], []),
        (["a", "b", "c"], ["c", "a", "b"], [2], [0]),
        (["a", "b", "c"], ["a", "b", "c"], [], []),
        ([], [], [], []),
        (["only"], ["other"], [0], [0]),
        (["h", "a", "b", "f"], ["h", "n", "a", "f", "t"], [2], [1, 4]),
    ] as [([String], [String], [Int], [Int])])
    func examples(old: [String], new: [String], deletions: [Int], insertions: [Int]) {
        #expect(TableRowDiff.changes(from: old, to: new) == TableRowDiff.Changes(deletions: deletions, insertions: insertions))
    }

    @Test("A swap has two right answers, and either is accepted")
    func swap() {
        let changes = TableRowDiff.changes(from: ["a", "b"], to: ["b", "a"])
        #expect(issues(changes, old: ["a", "b"], new: ["b", "a"], longestKept: 1) == [])
        #expect(changes.deletions.count == 1 && changes.insertions.count == 1)
    }

    @Test("Reversing a list keeps only one row")
    func reversed() {
        let old = (0..<50).map { "row\($0)" }
        let new = Array(old.reversed())
        let changes = TableRowDiff.changes(from: old, to: new)
        #expect(issues(changes, old: old, new: new, longestKept: 1) == [])
    }

    @Test("Random small lists give a valid diff with the fewest changes")
    func randomSmall() {
        var random = RowDiffRandom(seed: 73)
        let pool = (0..<12).map { "id\($0)" }
        var failures = 0
        for _ in 0..<500 where failures == 0 {
            let old = Array(pool.shuffled(using: &random).prefix(Int.random(in: 0...8, using: &random)))
            let new = Array(pool.shuffled(using: &random).prefix(Int.random(in: 0...8, using: &random)))
            let longest = lcsLength(old, new)
            #expect(longest == lisLength(old, new))
            let changes = TableRowDiff.changes(from: old, to: new)
            let found = issues(changes, old: old, new: new, longestKept: longest)
            if !found.isEmpty {
                failures += 1
                Issue.record("old \(old), new \(new): \(changes): \(found.joined(separator: "; "))")
            }
        }
    }

    @Test("A feed refresh: some rows removed, some added, nothing moved")
    func refresh() {
        var random = RowDiffRandom(seed: 2_000)
        let old = (0..<2_000).map { "post-\($0)" }
        var new: [String] = []
        var removed = 0, added = 0
        for (index, id) in old.enumerated() {
            if Int.random(in: 0..<6, using: &random) == 0 {
                new.append("fresh-\(index)")      // a new post appears here
                added += 1
            }
            if Int.random(in: 0..<7, using: &random) == 0 {
                removed += 1                       // this post was deleted
            } else {
                new.append(id)
            }
        }
        let changes = TableRowDiff.changes(from: old, to: new)
        #expect(changes.deletions.count == removed)
        #expect(changes.insertions.count == added)
        #expect(issues(changes, old: old, new: new, longestKept: old.count - removed) == [])
    }

    @Test("2,000 rows with deletions, insertions and moves")
    func large() {
        var random = RowDiffRandom(seed: 4_000)
        let old = (0..<2_000).map { "item-\($0)" }
        var new = old.filter { _ in Int.random(in: 0..<8, using: &random) != 0 }
        for index in 0..<150 {
            new.insert("new-\(index)", at: Int.random(in: 0...new.count, using: &random))
        }
        for _ in 0..<100 {
            let from = Int.random(in: 0..<new.count, using: &random)
            let row = new.remove(at: from)
            new.insert(row, at: Int.random(in: 0...new.count, using: &random))
        }
        let changes = TableRowDiff.changes(from: old, to: new)
        #expect(issues(changes, old: old, new: new, longestKept: lisLength(old, new)) == [])
    }
}
