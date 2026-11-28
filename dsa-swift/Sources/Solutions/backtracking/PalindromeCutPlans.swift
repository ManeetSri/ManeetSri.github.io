// Reference solution: Palindrome cut plans. First fill a table saying whether each slice reads the
// same both ways: letters[i...j] does when its two end letters match and the slice inside them is a
// palindrome too (a small DP, filled from the right so the inside is always ready). Then backtrack
// over cut positions: from `start`, try every end where letters[start...end] is a palindrome, and
// continue from end + 1. Only valid pieces are ever chosen.
// O(n²) for the table, plus O(n) per plan for the output (at most 2ⁿ⁻¹ plans); O(n²) extra space.

public enum PalindromeCutPlans {
    public static func plans(_ text: String) -> [[String]] {
        let letters = Array(text)
        let n = letters.count
        var isPalindrome = Array(repeating: Array(repeating: false, count: n), count: n)
        for i in stride(from: n - 1, through: 0, by: -1) {
            for j in i..<n where letters[i] == letters[j] && (j - i < 2 || isPalindrome[i + 1][j - 1]) {
                isPalindrome[i][j] = true
            }
        }

        var result: [[String]] = []
        var pieces: [String] = []

        func explore(from start: Int) {
            if start == n {
                result.append(pieces)
                return
            }
            for end in start..<n where isPalindrome[start][end] {
                pieces.append(String(letters[start...end]))         // cut after `end`
                explore(from: end + 1)
                pieces.removeLast()                                 // undo the cut
            }
        }

        explore(from: 0)
        return result
    }
}
