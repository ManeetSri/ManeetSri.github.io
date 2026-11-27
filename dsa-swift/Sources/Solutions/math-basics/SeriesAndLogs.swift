// Reference solution: Series and logs without overflow. Arithmetic: halve the even factor before
// multiplying, O(1). Geometric: add terms, computing a power only when another term follows. Logs:
// divide n down, which can't overflow. O(1), O(terms) and O(log n).

public enum SeriesAndLogs {
    public static func arithmeticSum(first: Int, step: Int, count: Int) -> Int {
        let pairSum = 2 * first + (count - 1) * step     // first + last
        if count % 2 == 0 {
            return (count / 2) * pairSum
        }
        return count * (pairSum / 2)                    // count is odd, so pairSum is even
    }

    public static func geometricSum(ratio: Int, terms: Int) -> Int {
        var total = 0
        var term = 1
        for index in 0..<terms {
            total += term
            if index < terms - 1 {                       // never compute the power past the last term
                term *= ratio
            }
        }
        return total
    }

    public static func floorLog(_ n: Int, base: Int) -> Int {
        var rest = n
        var count = 0
        while rest >= base {
            rest /= base
            count += 1
        }
        return count
    }
}
