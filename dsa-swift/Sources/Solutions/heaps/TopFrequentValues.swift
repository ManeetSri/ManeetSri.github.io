// Reference solution: Top K frequent values. Count with a dictionary (O(n)), then keep the k best
// (value, count) pairs in a heap whose top is the *worst* of them. A pair that beats the top replaces
// it. Popping the heap gives the k best from worst to best, so the result is reversed at the end.
// O(n + m log k) for m distinct values, O(m) space for the counts.

import DSAKit

public enum TopFrequentValues {
    public static func mostFrequent(_ values: [Int], k: Int) -> [Int] {
        var counts: [Int: Int] = [:]
        for value in values {
            counts[value, default: 0] += 1
        }
        // a comes before b when it's worse: fewer copies, or as many copies and a larger value
        func isWorse(_ a: (value: Int, count: Int), _ b: (value: Int, count: Int)) -> Bool {
            a.count != b.count ? a.count < b.count : a.value > b.value
        }
        var best = Heap<(value: Int, count: Int)>(areInIncreasingOrder: isWorse)
        for (value, count) in counts {
            if best.count < k {
                best.insert((value, count))
            } else if let worst = best.peek(), isWorse(worst, (value, count)) {
                best.replaceTop(with: (value, count))
            }
        }
        var result: [Int] = []
        while let entry = best.pop() {
            result.append(entry.value)
        }
        return result.reversed()
    }
}
