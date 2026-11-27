// Reference solution: Fewest edits between words. table[i][j] is the fewest edits turning the first i
// characters of the source into the first j of the target. Row 0 is j insertions and column 0 is i
// deletions. Matching last characters cost nothing (the diagonal); otherwise it's 1 plus the cheapest
// of replace (diagonal), delete (up) and insert (left). The script walks back from the corner, taking
// whichever arrow explains the cell's value, then reverses. O(n · m) time and space.

public enum WordEditScript {
    public enum Step: Equatable {
        case keep(Character)
        case replace(Character, with: Character)
        case delete(Character)
        case insert(Character)
    }

    private static func table(_ a: [Character], _ b: [Character]) -> [[Int]] {
        let n = a.count, m = b.count
        var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 0...n {
            for j in 0...m {
                if i == 0 {
                    table[i][j] = j
                } else if j == 0 {
                    table[i][j] = i
                } else if a[i - 1] == b[j - 1] {
                    table[i][j] = table[i - 1][j - 1]
                } else {
                    table[i][j] = 1 + min(table[i - 1][j - 1], table[i - 1][j], table[i][j - 1])
                }
            }
        }
        return table
    }

    public static func distance(from source: String, to target: String) -> Int {
        let a = Array(source), b = Array(target)
        return table(a, b)[a.count][b.count]
    }

    public static func script(from source: String, to target: String) -> [Step] {
        let a = Array(source), b = Array(target)
        let table = table(a, b)
        var steps: [Step] = []
        var i = a.count, j = b.count
        while i > 0 || j > 0 {
            if i > 0 && j > 0 && a[i - 1] == b[j - 1] && table[i][j] == table[i - 1][j - 1] {
                steps.append(.keep(a[i - 1]))
                i -= 1
                j -= 1
            } else if i > 0 && j > 0 && table[i][j] == table[i - 1][j - 1] + 1 {
                steps.append(.replace(a[i - 1], with: b[j - 1]))
                i -= 1
                j -= 1
            } else if i > 0 && table[i][j] == table[i - 1][j] + 1 {
                steps.append(.delete(a[i - 1]))
                i -= 1
            } else {
                steps.append(.insert(b[j - 1]))
                j -= 1
            }
        }
        return steps.reversed()
    }
}
