// Reference solution: Find and replace, left to right. Naive matching at each position: on a full match,
// append the replacement and jump past it; otherwise copy one character and step on. O(n · m) time in the
// worst case, O(n + output) space.

public enum LeftToRightReplace {
    public static func replacingAll(_ pattern: String, with replacement: String, in text: String) -> String {
        guard !pattern.isEmpty else { return text }
        let t = Array(text)
        let p = Array(pattern)
        var result = ""
        var start = 0
        while start < t.count {
            var matched = 0
            if start + p.count <= t.count {
                while matched < p.count && t[start + matched] == p[matched] {
                    matched += 1
                }
            }
            if matched == p.count {
                result += replacement
                start += p.count             // jump past the match: no overlaps
            } else {
                result.append(t[start])
                start += 1
            }
        }
        return result
    }
}
