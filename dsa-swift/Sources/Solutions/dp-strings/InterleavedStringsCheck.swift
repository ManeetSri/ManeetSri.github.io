// Reference solution: Interleave two strings. can[j] (one row of the table) says whether the first i
// characters of `first` and the first j of `second` can form the first i + j of `merged`: the last
// character came either from `first` (the cell above) or from `second` (the cell to the left), and it
// must equal merged[i + j - 1]. A greedy choice fails when both strings offer the right character, so
// the table keeps both possibilities. O(n · m) time, O(m) space.

public enum InterleavedStringsCheck {
    public static func canInterleave(_ first: String, _ second: String, into merged: String) -> Bool {
        let a = Array(first), b = Array(second), c = Array(merged)
        guard a.count + b.count == c.count else { return false }
        var can = Array(repeating: false, count: b.count + 1)
        for i in 0...a.count {
            for j in 0...b.count {
                if i == 0 && j == 0 {
                    can[j] = true
                } else {
                    let fromFirst = i > 0 && can[j] && a[i - 1] == c[i + j - 1]       // can[j] still holds row i - 1
                    let fromSecond = j > 0 && can[j - 1] && b[j - 1] == c[i + j - 1]
                    can[j] = fromFirst || fromSecond
                }
            }
        }
        return can[b.count]
    }
}
