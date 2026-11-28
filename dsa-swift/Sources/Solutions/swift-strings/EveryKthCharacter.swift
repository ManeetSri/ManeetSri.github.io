// Reference solution: Every kth character. Keep one String.Index and jump it k characters at a
// time with index(_:offsetBy:limitedBy:), which returns nil instead of running off the end.
// O(n) time in total (each character is stepped over once), O(n) space for the result.

public enum EveryKthCharacter {
    public static func pick(every k: Int, from text: String) -> String {
        var result = ""
        var index = text.startIndex
        while index < text.endIndex {
            result.append(text[index])
            guard let next = text.index(index, offsetBy: k, limitedBy: text.endIndex) else {
                break
            }
            index = next
        }
        return result
    }
}
