// Reference solution: Reverse the word order.
// split(separator:) skips empty pieces, so runs of spaces and spaces at the ends vanish.
// O(n) time, O(n) extra space.

public enum ReverseWordOrder {
    public static func reverse(_ sentence: String) -> String {
        sentence.split(separator: " ").reversed().joined(separator: " ")
    }
}
