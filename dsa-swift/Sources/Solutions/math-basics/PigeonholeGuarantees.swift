// Reference solution: Guaranteed by pigeonhole. Socks: the worst case is min(count, k − 1) of every
// colour, so one more draw forces a match. Remainders: n + 1 values, n remainders, so remember the first
// index of each remainder and stop at the first repeat. O(colours) and O(n).

public enum PigeonholeGuarantees {
    public static func drawsToGuarantee(matching k: Int, counts: [Int]) -> Int? {
        guard counts.contains(where: { $0 >= k }) else {
            return nil
        }
        var safeDraws = 0                       // the most draws without k of a kind
        for count in counts {
            safeDraws += min(count, k - 1)
        }
        return safeDraws + 1
    }

    public static func sharedRemainder(_ numbers: [Int]) -> (first: Int, second: Int) {
        let n = numbers.count - 1
        var firstSeen = Array(repeating: -1, count: n)
        for (index, value) in numbers.enumerated() {
            var remainder = value % n
            if remainder < 0 {
                remainder += n                  // Swift's % keeps the sign of value
            }
            if firstSeen[remainder] != -1 {
                return (firstSeen[remainder], index)
            }
            firstSeen[remainder] = index
        }
        return (-1, -1)                         // unreachable: a repeat is guaranteed
    }
}
