// Reference solution: How many longest rising subsequences. For each index, keep the best length of a
// rising subsequence ending there and how many subsequences reach that length. An earlier, smaller
// value j that gives a longer run takes over (length and count); one that ties adds its count. The
// answer adds the counts of every index whose length is the overall best.
// O(n²) time, O(n) space.

public enum LongestRisingCount {
    public static func count(_ values: [Int]) -> Int {
        var length = Array(repeating: 1, count: values.count)
        var ways = Array(repeating: 1, count: values.count)
        for i in values.indices {
            for j in 0..<i where values[j] < values[i] {
                if length[j] + 1 > length[i] {
                    length[i] = length[j] + 1
                    ways[i] = ways[j]
                } else if length[j] + 1 == length[i] {
                    ways[i] += ways[j]
                }
            }
        }
        let best = length.max() ?? 0
        var total = 0
        for i in values.indices where length[i] == best {
            total += ways[i]
        }
        return total
    }
}
