// Reference solution: Longest unique run. A variable window that never contains a repeat. A
// dictionary remembers where each character was last seen, so when the new character is already in
// the window, `left` jumps straight past its previous position. O(n) time, O(k) space for k distinct
// characters.

public enum LongestUniqueRun {
    public static func length(of text: String) -> Int {
        let chars = Array(text)
        var lastSeen: [Character: Int] = [:]
        var left = 0
        var best = 0
        for right in 0..<chars.count {
            if let previous = lastSeen[chars[right]], previous >= left {
                left = previous + 1             // jump past the earlier copy
            }
            lastSeen[chars[right]] = right
            best = max(best, right - left + 1)
        }
        return best
    }
}
