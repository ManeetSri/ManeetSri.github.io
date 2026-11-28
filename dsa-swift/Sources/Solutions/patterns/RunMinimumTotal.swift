// Reference solution: Sum of every trip's cheapest day. Count each day's share instead of each trip's
// minimum: day i is the minimum of (i − previous strictly lower day) × (next lower-or-equal day − i)
// trips, with the asymmetric tie rule so each trip has exactly one owner. One monotonic-stack pass finds
// both neighbours. O(n) time and space.

public enum RunMinimumTotal {
    public static func total(_ rates: [Int]) -> Int {
        let n = rates.count
        var previousLower = [Int](repeating: -1, count: n)
        var nextLowerOrEqual = [Int](repeating: n, count: n)
        var stack: [Int] = []                     // indexes with increasing rates
        for j in 0..<n {
            while let top = stack.last, rates[j] <= rates[top] {
                nextLowerOrEqual[top] = j         // j is the first later day at or below top's rate
                stack.removeLast()
            }
            previousLower[j] = stack.last ?? -1   // what's left below is strictly lower
            stack.append(j)
        }
        var sum = 0
        for i in 0..<n {
            sum += rates[i] * (i - previousLower[i]) * (nextLowerOrEqual[i] - i)
        }
        return sum
    }
}
