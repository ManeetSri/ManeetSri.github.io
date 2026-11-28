// Reference solution: Longest shared substring. run[j] (one row of the table) is the length of the
// longest common substring ending at first[i] and second[j - 1]: a match extends the diagonal by one,
// a mismatch resets it to 0. The answer is the best cell anywhere, not the corner. Running j downwards
// keeps run[j - 1] from the previous row. Replacing the best only when strictly longer keeps the one
// that ends, and so starts, earliest in `first`. O(n · m) time, O(m) space.

public enum LongestSharedSubstring {
    public static func longest(_ first: String, _ second: String) -> String {
        let a = Array(first), b = Array(second)
        var run = Array(repeating: 0, count: b.count + 1)
        var bestLength = 0
        var bestEnd = 0                                   // the best substring is a[bestEnd - bestLength..<bestEnd]
        for i in 0..<a.count {
            for j in stride(from: b.count, through: 1, by: -1) {
                if a[i] == b[j - 1] {
                    run[j] = run[j - 1] + 1
                    if run[j] > bestLength {
                        bestLength = run[j]
                        bestEnd = i + 1
                    }
                } else {
                    run[j] = 0
                }
            }
        }
        return String(a[(bestEnd - bestLength)..<bestEnd])
    }
}
