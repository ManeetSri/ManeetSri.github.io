import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NoAdjacentOnesTests {
    @Test("Small lengths, exactly", arguments: [
        (0, [""]),
        (1, ["0", "1"]),
        (2, ["00", "01", "10"]),
        (3, ["000", "001", "010", "100", "101"]),
        (4, ["0000", "0001", "0010", "0100", "0101", "1000", "1001", "1010"]),
    ])
    func smallLengths(length: Int, expected: [String]) {
        #expect(NoAdjacentOnes.strings(length: length) == expected)
    }

    @Test("The counts follow the Fibonacci numbers", arguments: Array(0...20))
    func counts(length: Int) {
        // 1, 2, 3, 5, 8, 13, …: fib(length + 2)
        var (a, b) = (1, 2)
        for _ in 0..<length {
            (a, b) = (b, a + b)
        }
        #expect(NoAdjacentOnes.strings(length: length).count == a)
    }

    @Test("Every string is valid, sorted and unique", arguments: [5, 10, 15])
    func validSortedUnique(length: Int) {
        let result = NoAdjacentOnes.strings(length: length)
        #expect(!result.isEmpty)
        #expect(result.allSatisfy { $0.count == length })
        #expect(result.allSatisfy { $0.allSatisfy { $0 == "0" || $0 == "1" } })
        #expect(result.allSatisfy { !$0.contains("11") })
        #expect(result == result.sorted())
        #expect(Set(result).count == result.count)
    }

    @Test("Includes the extremes for length 20")
    func extremes() {
        let result = NoAdjacentOnes.strings(length: 20)
        #expect(result.first == String(repeating: "0", count: 20))
        #expect(result.last == String(repeating: "10", count: 10))
        #expect(result.contains(String(repeating: "01", count: 10)))
    }
}
