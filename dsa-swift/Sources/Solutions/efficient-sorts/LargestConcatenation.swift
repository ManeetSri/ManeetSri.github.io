// Reference solution: The biggest joined number. Sort the numbers' digit strings with a custom
// order: a goes before b when a + b, read as digits, is bigger than b + a. That order is a strict
// weak ordering, so sorted(by:) can use it, and joining the sorted strings gives the answer. If the
// biggest piece is "0", every piece is 0, so the answer is "0". O(n log n) comparisons, each costing
// time proportional to the digits compared.

public enum LargestConcatenation {
    public static func largest(from numbers: [Int]) -> String {
        let pieces = numbers.map(String.init).sorted { a, b in
            a + b > b + a                                // same length, so this compares digits as numbers
        }
        if pieces.first == "0" {
            return "0"                                   // every piece is 0
        }
        return pieces.joined()
    }
}
