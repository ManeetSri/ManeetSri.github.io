// Reference solution: Smallest covering window. `need` counts how many more of each byte the window
// still needs (it goes negative for surplus), and `missing` is how many pattern characters are still
// uncovered. Grow on the right; while nothing is missing, record the window and shrink from the left.
// The substring is built once, at the end. O(n + m) time, O(1) space (128 slots for ASCII).

public enum SmallestCoveringWindow {
    public static func window(in text: String, covering pattern: String) -> String {
        let t = Array(text.utf8)
        let p = Array(pattern.utf8)
        guard !p.isEmpty, p.count <= t.count else { return "" }
        var need = [Int](repeating: 0, count: 128)
        for byte in p {
            need[Int(byte)] += 1
        }
        var missing = p.count
        var left = 0
        var bestStart = 0
        var bestLength = Int.max
        for right in 0..<t.count {
            let entering = Int(t[right])
            if need[entering] > 0 {
                missing -= 1                    // this copy was needed
            }
            need[entering] -= 1
            while missing == 0 {
                if right - left + 1 < bestLength {
                    bestLength = right - left + 1
                    bestStart = left
                }
                let leaving = Int(t[left])
                need[leaving] += 1
                if need[leaving] > 0 {
                    missing += 1                // dropped a needed copy
                }
                left += 1
            }
        }
        guard bestLength != Int.max else { return "" }
        return String(decoding: t[bestStart..<bestStart + bestLength], as: UTF8.self)
    }
}
