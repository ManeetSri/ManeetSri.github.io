import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// ⌈log₂ n!⌉ for n = 0...5.
private let budgets = [0, 0, 1, 3, 5, 7]

/// Every ordering of `items`.
private func permutations(_ items: [Int]) -> [[Int]] {
    guard items.count > 1 else { return [items] }
    var result: [[Int]] = []
    for (index, first) in items.enumerated() {
        var rest = items
        rest.remove(at: index)
        result += permutations(rest).map { [first] + $0 }
    }
    return result
}

/// Every array of `count` values drawn from 1, 2 and 3.
private func smallValueArrays(_ count: Int) -> [[Int]] {
    guard count > 0 else { return [[]] }
    return smallValueArrays(count - 1).flatMap { prefix in (1...3).map { prefix + [$0] } }
}

/// Sorts `values` with the solution, counting the calls to the comparator.
private func sortCounting(_ values: [Int], by isLess: (Int, Int) -> Bool) -> (result: [Int], calls: Int) {
    var calls = 0
    let result = FewestComparisonSort.sorted(values) { a, b in
        calls += 1
        return isLess(a, b)
    }
    return (result, calls)
}

@Suite struct FewestComparisonSortTests {
    @Test("The examples")
    func examples() {
        #expect(sortCounting([3, 1, 2], by: <).result == [1, 2, 3])
        #expect(sortCounting([4, 2, 3, 1], by: <).result == [1, 2, 3, 4])
        #expect(sortCounting([5, 3, 9, 1, 7], by: <).result == [1, 3, 5, 7, 9])
        #expect(sortCounting([5, 3, 9, 1, 7], by: >).result == [9, 7, 5, 3, 1])
        #expect(sortCounting([2, 2, 1, 2, 1], by: <).result == [1, 1, 2, 2, 2])
        #expect(sortCounting([], by: <) == ([], 0))
        #expect(sortCounting([8], by: <) == ([8], 0))
    }

    @Test("Every ordering of distinct values, within the budget", arguments: 0...5)
    func everyOrdering(count: Int) {
        var failures: [String] = []
        for input in permutations((0..<count).map { $0 + 1 }) {
            let (result, calls) = sortCounting(input, by: <)
            if failures.count < 3 && (result != input.sorted() || calls > budgets[count]) {
                failures.append("\(input) gave \(result) after \(calls) calls (allowed \(budgets[count]))")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Every input of 1s, 2s and 3s, within the budget", arguments: 0...5)
    func duplicates(count: Int) {
        var failures: [String] = []
        for input in smallValueArrays(count) {
            let (result, calls) = sortCounting(input, by: <)
            if failures.count < 3 && (result != input.sorted() || calls > budgets[count]) {
                failures.append("\(input) gave \(result) after \(calls) calls (allowed \(budgets[count]))")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Sorts by the comparator it's given, not by <")
    func customOrder() {
        var failures: [String] = []
        for input in permutations([10, 20, 30, 40, 50]) {
            let (result, calls) = sortCounting(input, by: >)
            if failures.count < 3 && (result != [50, 40, 30, 20, 10] || calls > 7) {
                failures.append("by >: \(input) gave \(result) after \(calls) calls")
            }
        }
        // Order by distance from zero: -2 and 2 tie, and so do -1 and 1
        for input in permutations([-2, 1, 2, -1, 0]) {
            let (result, calls) = sortCounting(input) { abs($0) < abs($1) }
            let ordered = zip(result, result.dropFirst()).allSatisfy { abs($0) <= abs($1) }
            if failures.count < 3 && (result.sorted() != [-2, -1, 0, 1, 2] || !ordered || calls > 7) {
                failures.append("by distance from 0: \(input) gave \(result) after \(calls) calls")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Extremes of Int")
    func extremes() {
        let (result, calls) = sortCounting([Int.max, 0, Int.min, -1, Int.max], by: <)
        #expect(result == [Int.min, -1, 0, Int.max, Int.max])
        #expect(calls <= 7)
    }
}
