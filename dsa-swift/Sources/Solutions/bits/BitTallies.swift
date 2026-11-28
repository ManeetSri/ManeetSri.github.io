// Reference solution: Bit tallies. i has the same set bits as i >> 1, plus its lowest bit, and the
// smaller count is already known. O(n) time, O(1) extra space apart from the answer.

public enum BitTallies {
    public static func tallies(upTo n: Int) -> [Int] {
        var counts = Array(repeating: 0, count: n + 1)
        for i in stride(from: 1, through: n, by: 1) {
            counts[i] = counts[i >> 1] + (i & 1)
        }
        return counts
    }
}
