// Reference solution: Keep the valid numbers. Flatten the rows, then convert and drop failures.
// O(total characters) time; O(n) space for the flattened entries and the result.

public enum KeepValidNumbers {
    public static func validNumbers(in rows: [[String]]) -> [Int] {
        rows.flatMap { $0 }.compactMap { Int($0) }
    }
}
