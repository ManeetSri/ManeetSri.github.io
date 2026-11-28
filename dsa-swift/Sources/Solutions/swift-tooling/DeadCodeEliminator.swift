// Reference solution: Deleting unused work. Walking backwards, `needed` holds the variables whose current
// value some kept line will still read. An assignment survives only if its variable is needed; then the
// variable stops being needed (this line sets it) and its operands start being needed. O(n) for n lines.

public enum DeadCodeEliminator {
    public static func optimise(_ program: [String]) -> [String] {
        var needed = Set<String>()
        var kept: [String] = []

        for line in program.reversed() {
            let words = line.split(separator: " ").map(String.init)
            if words[0] == "print" {
                kept.append(line)
                markNeeded(words[1], in: &needed)
            } else if needed.contains(words[0]) {
                kept.append(line)
                needed.remove(words[0])                    // remove first: x = x + 1 still needs x
                markNeeded(words[2], in: &needed)
                if words.count == 5 {
                    markNeeded(words[4], in: &needed)
                }
            }
        }
        return kept.reversed()
    }

    // Number literals are never needed; only names are
    private static func markNeeded(_ operand: String, in needed: inout Set<String>) {
        if let first = operand.first, first.isLetter {
            needed.insert(operand)
        }
    }
}
