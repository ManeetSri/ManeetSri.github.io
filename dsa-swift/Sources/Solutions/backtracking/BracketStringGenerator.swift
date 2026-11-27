// Reference solution: Generate balanced bracket strings. Build the string one character at a time,
// counting the open and close brackets placed so far. "(" is allowed while fewer than n are open, and
// ")" only while it has an unmatched "(" to close. Those two rules mean no invalid prefix is ever
// built, so every leaf is a valid answer and nothing is filtered afterwards.
// O(Cₙ · n) time, where Cₙ is the nth Catalan number (the number of answers); O(n) extra space.

public enum BracketStringGenerator {
    public static func balanced(pairs n: Int) -> [String] {
        var result: [String] = []
        var current: [Character] = []

        func explore(open: Int, close: Int) {
            if current.count == 2 * n {
                result.append(String(current))
                return
            }
            if open < n {
                current.append("(")
                explore(open: open + 1, close: close)
                current.removeLast()
            }
            if close < open {
                current.append(")")
                explore(open: open, close: close + 1)
                current.removeLast()
            }
        }

        explore(open: 0, close: 0)
        return result
    }
}
