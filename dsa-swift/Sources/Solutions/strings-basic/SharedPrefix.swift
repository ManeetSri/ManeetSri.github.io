// Reference solution: Longest shared prefix. Vertical scan: compare the words column by column,
// using the first word as the reference, and stop at the first column where any word ends or
// differs. O(S) time, where S is the total number of characters; O(S) space for the arrays.

public enum SharedPrefix {
    public static func longestCommonPrefix(_ words: [String]) -> String {
        guard let first = words.first else { return "" }
        let reference = Array(first)
        let others = words.dropFirst().map { Array($0) }
        for column in 0..<reference.count {
            for chars in others where column == chars.count || chars[column] != reference[column] {
                return String(reference[0..<column])
            }
        }
        return first
    }
}
