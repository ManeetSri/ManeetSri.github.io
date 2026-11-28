// Non-comparison sorts for integers (M32 · Non-comparison sorts and cyclic sort).
//
// Neither method ever compares two elements with `<`. Counting sort counts how many times each
// value appears; radix sort places numbers one byte at a time. That's how they beat the
// O(n log n) limit that every comparison sort is stuck with, when the data allows it.
//
// - countingSorted() is O(n + k), where k is the range of values, max − min + 1. It's the right
//   tool when that range is small: ages, scores out of 100, dice rolls, letters.
// - radixSorted() is O(n) for any Int values: eight stable counting passes, one per byte. It uses
//   O(n) extra memory and has a larger constant than counting sort, so it wins only for large
//   arrays of numbers with a wide range.

extension Array where Element == Int {
    /// Returns the numbers in increasing order, sorted by counting sort.
    ///
    /// Counts how many times each value from the smallest to the largest appears, then writes
    /// every value back out as many times as it was counted. Negative numbers work: each value is
    /// counted in slot `value - min`.
    ///
    /// ```swift
    /// [3, -1, 2, 3, 0].countingSorted()     // [-1, 0, 2, 3, 3]
    /// ```
    ///
    /// - Complexity: O(n + k) time and O(n + k) memory, where k = max − min + 1. Use it only when
    ///   k is not much bigger than n: sorting `[0, 1_000_000_000]` would count a billion slots.
    /// - Precondition: max − min must fit in an `Int`, or the method stops with a precondition
    ///   failure. Use `radixSorted()` for numbers spread across the whole `Int` range.
    public func countingSorted() -> [Int] {
        guard var low = first else { return [] }
        var high = low
        for value in self {
            if value < low { low = value }
            if value > high { high = value }
        }
        let (span, overflow) = high.subtractingReportingOverflow(low)
        precondition(!overflow && span < Int.max, "countingSorted(): the range of values is too wide to count")

        var counts = [Int](repeating: 0, count: span + 1)
        for value in self {
            counts[value - low] += 1             // can't overflow: value - low is at most span
        }
        var sorted: [Int] = []
        sorted.reserveCapacity(count)
        for (offset, times) in counts.enumerated() where times > 0 {
            sorted.append(contentsOf: repeatElement(low + offset, count: times))
        }
        return sorted
    }

    /// Returns the numbers in increasing order, sorted by least-significant-digit radix sort in
    /// base 256.
    ///
    /// Each pass is a stable counting sort on one byte, from the lowest byte to the highest. Because
    /// every pass keeps the order the earlier passes made among equal bytes, the numbers end up
    /// sorted by all their bytes. Passes where every number has the same byte are skipped, so small
    /// numbers take fewer passes.
    ///
    /// Negative numbers: before sorting, each value's bit pattern has its sign bit flipped. That
    /// maps `Int.min...Int.max` onto `0...UInt.max` in the same order (negatives first), so the
    /// whole `Int` range works, `Int.min` included, with no special cases. The flip is undone at
    /// the end.
    ///
    /// ```swift
    /// [170, -45, 75, 0, -802, 24].radixSorted()     // [-802, -45, 0, 24, 75, 170]
    /// ```
    ///
    /// - Complexity: O(d · (n + 256)) time, with d ≤ 8 passes for 64-bit integers, so O(n). O(n)
    ///   extra memory.
    public func radixSorted() -> [Int] {
        guard count > 1 else { return self }
        let signBit: UInt = 1 << (UInt.bitWidth - 1)
        var keys = map { UInt(bitPattern: $0) ^ signBit }
        var buffer = [UInt](repeating: 0, count: count)

        var shift = 0
        while shift < UInt.bitWidth {
            var counts = [Int](repeating: 0, count: 256)
            for key in keys {
                counts[Int((key >> UInt(shift)) & 0xFF)] += 1
            }
            if counts.contains(count) {          // every key has the same byte here: nothing to do
                shift += 8
                continue
            }
            // Turn the counts into starting positions (an exclusive prefix sum)
            var start = 0
            for byte in 0..<256 {
                let times = counts[byte]
                counts[byte] = start
                start += times
            }
            // Place every key at the next free position for its byte, in order: that's stable
            for key in keys {
                let byte = Int((key >> UInt(shift)) & 0xFF)
                buffer[counts[byte]] = key
                counts[byte] += 1
            }
            swap(&keys, &buffer)
            shift += 8
        }
        return keys.map { Int(bitPattern: $0 ^ signBit) }
    }
}
