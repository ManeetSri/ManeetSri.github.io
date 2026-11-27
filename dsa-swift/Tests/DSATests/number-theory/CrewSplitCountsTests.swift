import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CrewSplitCountsTests {
    private let p = 1_000_000_007

    private func power(_ base: Int, _ exponent: Int) -> Int {
        var result = 1
        var base = base % p
        var exponent = exponent
        while exponent > 0 {
            if exponent & 1 == 1 { result = result * base % p }
            base = base * base % p
            exponent >>= 1
        }
        return result
    }

    /// Counts the splits of n tasks by number of crews, by listing every split: each task joins an
    /// existing crew or starts the next new one
    private func splitsByCrews(_ n: Int) -> [Int] {
        var counts = Array(repeating: 0, count: n + 1)
        func place(_ task: Int, _ crews: Int) {
            if task == n {
                counts[crews] += 1
                return
            }
            for _ in 0..<crews {
                place(task + 1, crews)
            }
            place(task + 1, crews + 1)
        }
        place(0, 0)
        return counts
    }

    /// Counts the permutations of n people by number of cycles, by listing every permutation
    private func permutationsByCycles(_ n: Int) -> [Int] {
        var counts = Array(repeating: 0, count: n + 1)
        var perm = Array(0..<n)
        func cycles() -> Int {
            var seen = Array(repeating: false, count: n)
            var total = 0
            for start in 0..<n where !seen[start] {
                total += 1
                var i = start
                while !seen[i] {
                    seen[i] = true
                    i = perm[i]
                }
            }
            return total
        }
        func permute(_ k: Int) {
            if k == n {
                counts[cycles()] += 1
                return
            }
            for i in k..<n {
                perm.swapAt(k, i)
                permute(k + 1)
                perm.swapAt(k, i)
            }
        }
        permute(0)
        return counts
    }

    @Test("The examples")
    func examples() {
        let planner = CrewSplitCounts.Planner(maxTasks: 10)
        #expect(planner.unnamedCrews(tasks: 4, crews: 2) == 7)
        #expect(planner.namedCrews(tasks: 4, crews: 2) == 14)
        #expect(planner.anyCrews(tasks: 4) == 15)
        #expect(planner.roundTables(people: 4, tables: 2) == 11)
        #expect(planner.unnamedCrews(tasks: 7, crews: 3) == 301)
        #expect(planner.anyCrews(tasks: 0) == 1)
        #expect(planner.unnamedCrews(tasks: 3, crews: 5) == 0)
        #expect(planner.roundTables(people: 6, tables: 1) == 120)
    }

    @Test("Zero tasks, zero crews, and too many crews")
    func edges() {
        let planner = CrewSplitCounts.Planner(maxTasks: 6)
        #expect(planner.unnamedCrews(tasks: 0, crews: 0) == 1)
        #expect(planner.namedCrews(tasks: 0, crews: 0) == 1)
        #expect(planner.roundTables(people: 0, tables: 0) == 1)
        #expect(planner.unnamedCrews(tasks: 5, crews: 0) == 0)
        #expect(planner.roundTables(people: 5, tables: 0) == 0)
        #expect(planner.unnamedCrews(tasks: 0, crews: 3) == 0)
        #expect(planner.namedCrews(tasks: 2, crews: 6) == 0)
        #expect(planner.unnamedCrews(tasks: 6, crews: 6) == 1)
        #expect(planner.namedCrews(tasks: 6, crews: 6) == 720)
        let tiny = CrewSplitCounts.Planner(maxTasks: 0)
        #expect(tiny.anyCrews(tasks: 0) == 1)
    }

    @Test("Bell numbers and Stirling rows from the lesson's tables")
    func knownValues() {
        let planner = CrewSplitCounts.Planner(maxTasks: 10)
        #expect((0...10).map { planner.anyCrews(tasks: $0) } == [1, 1, 2, 5, 15, 52, 203, 877, 4_140, 21_147, 115_975])
        #expect((1...7).map { planner.unnamedCrews(tasks: 7, crews: $0) } == [1, 63, 301, 350, 140, 21, 1])
        #expect((1...6).map { planner.roundTables(people: 6, tables: $0) } == [120, 274, 225, 85, 15, 1])
        #expect((2...10).map { planner.unnamedCrews(tasks: $0, crews: 2) } == (2...10).map { (1 << ($0 - 1)) - 1 })
    }

    @Test("Matches listing every split and every seating, up to 8 people")
    func bruteForce() {
        let planner = CrewSplitCounts.Planner(maxTasks: 8)
        for n in 0...8 {
            let splits = splitsByCrews(n)
            #expect((0...n).map { planner.unnamedCrews(tasks: n, crews: $0) } == splits, "n = \(n)")
            #expect(planner.anyCrews(tasks: n) == splits.reduce(0, +), "n = \(n)")
        }
        for n in 0...7 {
            #expect((0...n).map { planner.roundTables(people: n, tables: $0) } == permutationsByCycles(n), "n = \(n)")
        }
    }

    @Test("Large tables match independent formulas modulo the prime")
    func largeTables() {
        let n = 1_000
        let planner = CrewSplitCounts.Planner(maxTasks: n)
        // Bell numbers from the Bell triangle
        var row = [1]
        var bells = [1]
        for _ in 1...n {
            var next = [row[row.count - 1]]
            for value in row {
                next.append((next[next.count - 1] + value) % p)
            }
            row = next
            bells.append(row[0])
        }
        for m in [1, 2, 25, 100, 500, 999, 1_000] {
            #expect(planner.anyCrews(tasks: m) == bells[m], "Bell(\(m))")
        }
        // Named crews are onto functions: inclusion–exclusion
        var binomials = [[1]]
        for k in 1...40 {
            var next = [1]
            for j in 1..<k { next.append((binomials[k - 1][j - 1] + binomials[k - 1][j]) % p) }
            next.append(1)
            binomials.append(next)
        }
        for (tasks, crews) in [(1_000, 1), (1_000, 2), (1_000, 40), (777, 13), (40, 40), (100, 39)] {
            var onto = 0
            for j in 0...crews {
                let term = binomials[crews][j] * power(crews - j, tasks) % p
                onto = (onto + (j.isMultiple(of: 2) ? term : p - term)) % p
            }
            #expect(planner.namedCrews(tasks: tasks, crews: crews) == onto, "named(\(tasks), \(crews))")
        }
        // Each row of round-table counts adds up to n!
        var factorial = 1
        for m in 1...n {
            factorial = factorial * m % p
            if m % 250 == 0 || m == 1 {
                let total = (0...m).reduce(0) { ($0 + planner.roundTables(people: m, tables: $1)) % p }
                #expect(total == factorial, "row \(m) of round tables")
            }
        }
        // Lots of O(1) queries
        var checksum = 0
        for i in 0..<300_000 {
            let tasks = i % (n + 1)
            let crews = (i * 7) % (n + 1)
            checksum = (checksum + planner.unnamedCrews(tasks: tasks, crews: crews) + planner.namedCrews(tasks: tasks, crews: crews)) % p
        }
        #expect(checksum > 0)
    }
}
