import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LargestConcatenationTests {
    @Test("Joins small lists into the biggest number", arguments: [
        ([5, 56, 50], "56550"),
        ([12, 121], "12121"),
        ([20, 2, 202], "220220"),
        ([8, 81, 819], "881981"),
        ([1, 34, 3, 98, 9, 76, 45, 4], "998764543431"),
        ([10, 1], "110"),
        ([0, 7, 70], "7700"),
        ([0, 0, 0], "0"),
        ([0], "0"),
        ([7], "7"),
        ([1_000_000_000, 9], "91000000000"),
    ])
    func small(numbers: [Int], expected: String) {
        #expect(LargestConcatenation.largest(from: numbers) == expected)
    }

    @Test("Uses every digit of every number exactly once")
    func keepsDigits() {
        let numbers = [3, 30, 34, 5, 9, 300, 0, 44]
        let result = LargestConcatenation.largest(from: numbers)
        #expect(result.sorted() == numbers.map(String.init).joined().sorted())
    }

    @Test("Beats every other order on small lists")
    func beatsEveryOrder() {
        // Try every order of a few small lists and keep the biggest result
        func permutations(_ items: [Int]) -> [[Int]] {
            guard items.count > 1 else { return [items] }
            return items.indices.flatMap { index -> [[Int]] in
                var rest = items
                let first = rest.remove(at: index)
                return permutations(rest).map { [first] + $0 }
            }
        }
        let lists: [[Int]] = [[3, 30, 34], [9, 91, 919, 99], [0, 1, 10, 100], [6, 66, 667, 665], [5, 55, 505, 550]]
        var mismatches = 0
        for list in lists {
            // Every order gives a string of the same length, so comparing strings compares numbers
            let joined: [String] = permutations(list).map { order in order.map(String.init).joined() }
            let best: String = joined.max() ?? ""
            if LargestConcatenation.largest(from: list) != best { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("10,000 numbers")
    func large() {
        let numbers = (0..<10_000).map { ($0 * 7_919) % 100_000 }
        let result = LargestConcatenation.largest(from: numbers)
        let expected = numbers.map(String.init).sorted { $0 + $1 > $1 + $0 }.joined()
        #expect(result == expected)
        #expect(result.hasPrefix("9"))
    }

    @Test("10,000 zeros make 0")
    func manyZeros() {
        #expect(LargestConcatenation.largest(from: Array(repeating: 0, count: 10_000)) == "0")
    }
}
