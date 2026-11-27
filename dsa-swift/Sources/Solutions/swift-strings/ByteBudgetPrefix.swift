// Reference solution: Fit a byte budget. Walk whole Characters, adding each one's UTF-8 size,
// and cut just before the first one that doesn't fit. O(n) time for n bytes, O(n) space.

public enum ByteBudgetPrefix {
    public static func prefix(of text: String, maxBytes: Int) -> String {
        if text.utf8.count <= maxBytes {
            return text
        }
        var used = 0
        var end = text.startIndex
        for index in text.indices {
            let size = String(text[index]).utf8.count
            if used + size > maxBytes {
                break
            }
            used += size
            end = text.index(after: index)
        }
        return String(text[..<end])
    }
}
