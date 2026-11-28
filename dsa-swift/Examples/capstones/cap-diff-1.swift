// Generated from src/dsa/content/lessons/capstones/cap-diff.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Edit<Element> {
    case keep(Element)
    case delete(Element)
    case insert(Element)
}

/// Myers' O(ND) diff: the shortest edit script turning `a` into `b`.
/// v[k] holds the furthest x reached on diagonal k = x - y; trace keeps v before each round.
func myersDiff<Element: Equatable>(_ a: [Element], _ b: [Element]) -> [Edit<Element>] {
    let n = a.count, m = b.count, most = n + m
    guard most > 0 else { return [] }
    let offset = most                                   // diagonals run from -most to most
    var v = Array(repeating: 0, count: 2 * most + 2)
    var trace: [[Int]] = []
    rounds: for d in 0...most {
        trace.append(v)
        for k in stride(from: -d, through: d, by: 2) {
            var x: Int
            if k == -d || (k != d && v[offset + k - 1] < v[offset + k + 1]) {
                x = v[offset + k + 1]                   // step down from diagonal k + 1: an insertion
            } else {
                x = v[offset + k - 1] + 1               // step right from diagonal k - 1: a deletion
            }
            var y = x - k
            while x < n && y < m && a[x] == b[y] {      // then slide down the snake of matches for free
                x += 1
                y += 1
            }
            v[offset + k] = x
            if x >= n && y >= m { break rounds }
        }
    }
    // Walk back from (n, m), asking each round which neighbouring diagonal we came from
    var edits: [Edit<Element>] = []
    var x = n, y = m
    for d in stride(from: trace.count - 1, through: 0, by: -1) {
        let v = trace[d]
        let k = x - y
        let previousK = (k == -d || (k != d && v[offset + k - 1] < v[offset + k + 1])) ? k + 1 : k - 1
        let previousX = v[offset + previousK]
        let previousY = previousX - previousK
        while x > previousX && y > previousY {         // the snake, backwards
            edits.append(.keep(a[x - 1]))
            x -= 1
            y -= 1
        }
        if d > 0 {
            if x == previousX {
                edits.append(.insert(b[y - 1]))
            } else {
                edits.append(.delete(a[x - 1]))
            }
        }
        (x, y) = (previousX, previousY)
    }
    return edits.reversed()
}

/// The LCS length by the classic table, to cross-check: D = n + m - 2 × LCS
func lcsLength<Element: Equatable>(_ a: [Element], _ b: [Element]) -> Int {
    var table = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
    for i in stride(from: 1, through: a.count, by: 1) {
        for j in stride(from: 1, through: b.count, by: 1) {
            table[i][j] = a[i - 1] == b[j - 1] ? table[i - 1][j - 1] + 1 : max(table[i - 1][j], table[i][j - 1])
        }
    }
    return table[a.count][b.count]
}

/// A unified diff: changed lines, with `context` unchanged lines around them, grouped into hunks
func unifiedDiff(_ old: [String], _ new: [String], oldName: String, newName: String, context: Int) -> [String] {
    var rows: [(edit: Edit<String>, old: Int, new: Int)] = []    // each edit, with the line indexes it sits at
    var i = 0, j = 0
    for edit in myersDiff(old, new) {
        rows.append((edit, i, j))
        switch edit {
        case .keep: (i, j) = (i + 1, j + 1)
        case .delete: i += 1
        case .insert: j += 1
        }
    }
    func isChange(_ edit: Edit<String>) -> Bool {
        if case .keep = edit { return false }
        return true
    }
    var hunks: [ClosedRange<Int>] = []
    for index in rows.indices where isChange(rows[index].edit) {
        let range = max(index - context, 0)...min(index + context, rows.count - 1)
        if let last = hunks.last, range.lowerBound <= last.upperBound + 1 {
            hunks[hunks.count - 1] = last.lowerBound...range.upperBound   // contexts touch: one hunk
        } else {
            hunks.append(range)
        }
    }
    guard !hunks.isEmpty else { return [] }
    /// "start,count" with 1-based lines; a single line is just "start"; an empty side names the line before
    func span(_ start: Int, _ count: Int) -> String {
        count == 1 ? "\(start + 1)" : "\(count == 0 ? start : start + 1),\(count)"
    }
    var lines = ["--- \(oldName)", "+++ \(newName)"]
    for hunk in hunks {
        let slice = rows[hunk]
        let oldCount = slice.filter { if case .insert = $0.edit { return false } else { return true } }.count
        let newCount = slice.filter { if case .delete = $0.edit { return false } else { return true } }.count
        lines.append("@@ -\(span(slice.first!.old, oldCount)) +\(span(slice.first!.new, newCount)) @@")
        for row in slice {
            switch row.edit {
            case .keep(let text): lines.append(" " + text)
            case .delete(let text): lines.append("-" + text)
            case .insert(let text): lines.append("+" + text)
            }
        }
    }
    return lines
}

func describe(_ edits: [Edit<Character>]) -> String {
    edits.map { edit in
        switch edit {
        case .keep(let c): return " \(c)"
        case .delete(let c): return "-\(c)"
        case .insert(let c): return "+\(c)"
        }
    }.joined(separator: " ")
}

let a = Array("ABCABBA"), b = Array("CBABAC")
let script = myersDiff(a, b)
let changes = script.filter { if case .keep = $0 { return false } else { return true } }.count
print(describe(script))
print("D =", changes, "| n + m - 2 × LCS =", a.count + b.count - 2 * lcsLength(a, b))

for (old, new) in [("", "abc"), ("abc", ""), ("same", "same"), ("kitten", "sitting")] {
    let edits = myersDiff(Array(old), Array(new))
    print("\"\(old)\" → \"\(new)\":", describe(edits))
}

let before = """
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello")
            .padding()
    }
}

#Preview {
    ContentView()
}
"""
let after = """
import SwiftUI

struct ContentView: View {
    @State private var name = "Maneet"

    var body: some View {
        Text("Hello, " + name)
            .padding()
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
"""
let oldLines = before.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
let newLines = after.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
for line in unifiedDiff(oldLines, newLines, oldName: "a/ContentView.swift", newName: "b/ContentView.swift", context: 1) {
    print(line)
}
