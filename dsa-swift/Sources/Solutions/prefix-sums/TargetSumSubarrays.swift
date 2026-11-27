// Reference solution: Target-sum subarrays. One pass with a running prefix sum and a dictionary of the
// prefix values seen so far: counts of each value for `count`, the first position of each value for
// `longest`. O(n) average time, O(n) space.

public enum TargetSumSubarrays {
    public static func count(in numbers: [Int], summingTo target: Int) -> Int {
        var seen: [Int: Int] = [0: 1]          // the empty prefix
        var running = 0
        var total = 0
        for value in numbers {
            running += value
            total += seen[running - target, default: 0]
            seen[running, default: 0] += 1
        }
        return total
    }

    public static func longest(in numbers: [Int], summingTo target: Int) -> Int {
        var firstSeen: [Int: Int] = [0: 0]     // prefix value -> smallest i with prefix[i] equal to it
        var running = 0
        var best = 0
        for (index, value) in numbers.enumerated() {
            running += value
            let end = index + 1
            if let start = firstSeen[running - target] {
                best = max(best, end - start)
            }
            if firstSeen[running] == nil {
                firstSeen[running] = end
            }
        }
        return best
    }
}
