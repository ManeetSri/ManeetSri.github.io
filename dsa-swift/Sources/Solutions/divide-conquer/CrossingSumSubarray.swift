// Reference solution: Best run by splitting in half. The best run lies entirely in the left half,
// entirely in the right half, or crosses the middle. The crossing run is the best run ending at mid - 1
// (scanning leftwards) plus the best run starting at mid (scanning rightwards); both scans start from the
// elements next to the middle, so neither piece can be empty. T(n) = 2T(n/2) + n: O(n log n) time,
// O(log n) recursion stack.

public enum CrossingSumSubarray {
    public static func bestSum(_ numbers: [Int]) -> Int {
        bestSum(numbers, 0, numbers.count)
    }

    private static func bestSum(_ numbers: [Int], _ low: Int, _ high: Int) -> Int {
        if high - low == 1 {
            return numbers[low]
        }
        let mid = low + (high - low) / 2
        var sum = 0
        var bestLeft = numbers[mid - 1]
        for index in stride(from: mid - 1, through: low, by: -1) {
            sum += numbers[index]
            bestLeft = max(bestLeft, sum)
        }
        sum = 0
        var bestRight = numbers[mid]
        for index in mid..<high {
            sum += numbers[index]
            bestRight = max(bestRight, sum)
        }
        return max(bestSum(numbers, low, mid), bestSum(numbers, mid, high), bestLeft + bestRight)
    }
}
