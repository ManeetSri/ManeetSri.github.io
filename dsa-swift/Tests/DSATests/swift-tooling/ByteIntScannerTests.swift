import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ByteIntScannerTests {
    private func bytes(_ text: String) -> [UInt8] {
        Array(text.utf8)
    }

    @Test("Scans integers separated by whitespace", arguments: [
        ("3 9 4", [3, 9, 4]),
        ("42", [42]),
        ("-5 0 12", [-5, 0, 12]),
        ("10\n-3\n7\n", [10, -3, 7]),
        ("  1   2\t\t3  ", [1, 2, 3]),
        ("5\r\n6\r\n", [5, 6]),
        ("007 -0", [7, 0]),
    ])
    func scans(text: String, expected: [Int]) {
        #expect(ByteIntScanner.integers(in: bytes(text)) == expected)
    }

    @Test("No numbers gives an empty array", arguments: ["", " ", "\n\n", " \t\r\n "])
    func empty(text: String) {
        #expect(ByteIntScanner.integers(in: bytes(text)) == [])
    }

    @Test("Large values up to 10^18")
    func largeValues() {
        let text = "1000000000000000000 -1000000000000000000 999999999999999999"
        #expect(ByteIntScanner.integers(in: bytes(text)) == [1_000_000_000_000_000_000, -1_000_000_000_000_000_000, 999_999_999_999_999_999])
    }

    @Test("The reader returns one number per call, then nil")
    func readerSteps() {
        var reader = ByteIntScanner.Reader(bytes("4\n10 -3\n  7\n100\n"))
        #expect(reader.nextInt() == 4)
        #expect(reader.nextInt() == 10)
        #expect(reader.nextInt() == -3)
        #expect(reader.nextInt() == 7)
        #expect(reader.nextInt() == 100)
        #expect(reader.nextInt() == nil)
        #expect(reader.nextInt() == nil)
    }

    @Test("A count followed by that many numbers")
    func countThenNumbers() {
        var reader = ByteIntScanner.Reader(bytes("3\n8 -1 5\n"))
        let count = reader.nextInt() ?? 0
        var total = 0
        for _ in 0..<count {
            total += reader.nextInt() ?? 0
        }
        #expect(count == 3)
        #expect(total == 12)
    }

    @Test("Scans a large input")
    func largeInput() {
        let numbers = (0..<100_000).map { ($0 * 7_919) % 2_000_001 - 1_000_000 }
        let text = numbers.map(String.init).joined(separator: " ") + "\n"
        #expect(ByteIntScanner.integers(in: bytes(text)) == numbers)
    }
}
