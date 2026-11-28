// Reference solution: Smallest number after removals. Greedy with a stack of kept digits: while a
// removal is left and the last kept digit is bigger than the new one, drop it, because a smaller
// digit further left always wins. The kept digits never decrease, so leftover removals come off
// the end. O(n) time: each digit is pushed and popped at most once. O(n) space.

public enum SmallestAfterRemovals {
    public static func smallest(_ digits: String, removing k: Int) -> String {
        var kept: [Character] = []
        var removalsLeft = k
        for digit in digits {
            while removalsLeft > 0, let last = kept.last, last > digit {
                kept.removeLast()
                removalsLeft -= 1
            }
            kept.append(digit)
        }
        kept.removeLast(min(removalsLeft, kept.count))
        let trimmed = kept.drop { $0 == "0" }
        return trimmed.isEmpty ? "0" : String(trimmed)
    }
}
