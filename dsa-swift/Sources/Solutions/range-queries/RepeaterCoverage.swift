// Reference solution: Repeater coverage. Coverage only changes at endpoints, so compress them, put
// +1/−1 on their ranks in a difference array, and sweep the pieces between neighbouring endpoints.
// A running length grows by each reliable piece's real length and resets at an unreliable one.
// O(n log n) time, O(n) space.

public enum RepeaterCoverage {
    public static func longestReliableStretch(repeaters: [[Int]], atLeast k: Int) -> Int {
        let points = Array(Set(repeaters.flatMap { [$0[0], $0[1]] })).sorted()
        var rankOf: [Int: Int] = [:]
        for (rank, point) in points.enumerated() { rankOf[point] = rank }

        var change = [Int](repeating: 0, count: points.count)
        for repeater in repeaters {
            change[rankOf[repeater[0]]!] += 1
            change[rankOf[repeater[1]]!] -= 1
        }

        var covering = 0
        var running = 0
        var longest = 0
        for i in points.indices.dropLast() {
            covering += change[i]                     // the coverage of points[i] ..< points[i + 1]
            if covering >= k {
                running += points[i + 1] - points[i]  // real length, from the real coordinates
                longest = max(longest, running)
            } else {
                running = 0
            }
        }
        return longest
    }
}
