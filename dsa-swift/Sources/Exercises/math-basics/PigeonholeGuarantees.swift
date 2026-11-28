// Problem: Guaranteed by pigeonhole (M15 · The pigeonhole principle)

public enum PigeonholeGuarantees {
    /// The fewest blind draws that guarantee `k` socks of one colour, where `counts[i]` socks have
    /// colour i, or nil if no colour has `k` socks.
    public static func drawsToGuarantee(matching k: Int, counts: [Int]) -> Int? {
        // Write your solution here, then run:
        // swift test --filter PigeonholeGuaranteesTests
        return 0
    }

    /// For n + 1 numbers, indexes first < second whose values leave the same remainder modulo n,
    /// choosing the pair with the smallest second index. O(n).
    public static func sharedRemainder(_ numbers: [Int]) -> (first: Int, second: Int) {
        return (-1, -1)
    }
}
