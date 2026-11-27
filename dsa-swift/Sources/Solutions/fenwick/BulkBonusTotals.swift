// Reference solution: Bulk bonus totals. The starting amounts never change, so a prefix-sum array
// answers their part of every total. The bonuses are range additions with range sums: keep the
// difference array d in two Fenwick trees, one holding d[j] and one holding j × d[j]. The bonus total
// of the first p desks is (p + 1) × Σ d[j] − Σ j × d[j] over j ≤ p, and a range is two of those.
// O((n + q) log n) time, O(n) space.

public enum BulkBonusTotals {
    public static func process(initial: [Int], operations: [[Int]]) -> [Int] {
        let n = initial.count
        var start = [0]                                   // start[p] = the first p starting amounts
        for amount in initial {
            start.append(start.last! + amount)
        }
        var plain = Array(repeating: 0, count: n + 2)     // Fenwick trees over positions 1...n + 1
        var weighted = Array(repeating: 0, count: n + 2)

        func add(_ tree: inout [Int], _ delta: Int, at position: Int) {
            var i = position
            while i < tree.count {
                tree[i] += delta
                i += i & -i
            }
        }
        func prefix(_ tree: [Int], _ position: Int) -> Int {
            var i = position, total = 0
            while i > 0 {
                total += tree[i]
                i -= i & -i
            }
            return total
        }
        // Everything paid to desks 1...p (1-indexed), starting amounts included
        func paid(through p: Int) -> Int {
            start[p] + (p + 1) * prefix(plain, p) - prefix(weighted, p)
        }

        var answers: [Int] = []
        for operation in operations {
            let left = operation[1] + 1, right = operation[2] + 1   // 1-indexed inside
            if operation[0] == 0 {
                let amount = operation[3]
                add(&plain, amount, at: left)
                add(&plain, -amount, at: right + 1)
                add(&weighted, amount * left, at: left)
                add(&weighted, -amount * (right + 1), at: right + 1)
            } else {
                answers.append(paid(through: right) - paid(through: left - 1))
            }
        }
        return answers
    }
}
