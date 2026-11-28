// Reference solution: Expand a run-length code. Digits build the current count (count * 10 + digit);
// any other character finishes the previous run, with no digits meaning a count of 1, and starts a new
// one. The last run is written after the loop. O(n + L) time for a code of n characters expanding to L.

public enum RunCodeExpander {
    public static func expand(_ code: String) -> String {
        var result = ""
        var current: Character? = nil
        var count = 0
        for character in code {
            if let digit = character.wholeNumberValue {
                count = count * 10 + digit
            } else {
                if let previous = current {
                    result += String(repeating: previous, count: max(count, 1))
                }
                current = character
                count = 0
            }
        }
        if let previous = current {
            result += String(repeating: previous, count: max(count, 1))   // the last run
        }
        return result
    }
}
