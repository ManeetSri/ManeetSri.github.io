// Reference solution: Product of everything else. Left products go straight into the answer, then a
// sweep from the right multiplies in a running suffix product. No division, so zeros need no special
// case. O(n) time, O(1) extra space besides the output.

public enum ProductExceptSelf {
    public static func products(of numbers: [Int]) -> [Int] {
        let n = numbers.count
        var answer = Array(repeating: 1, count: n)
        var prefix = 1
        for i in 0..<n {
            answer[i] = prefix
            prefix *= numbers[i]
        }
        var suffix = 1
        for i in stride(from: n - 1, through: 0, by: -1) {
            answer[i] *= suffix
            suffix *= numbers[i]
        }
        return answer
    }
}
