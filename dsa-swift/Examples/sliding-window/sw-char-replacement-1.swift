// Generated from src/dsa/content/lessons/sliding-window/sw-char-replacement.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func repaintCost(_ window: String) -> Int {
    var counts: [Character: Int] = [:]
    for ch in window {
        counts[ch, default: 0] += 1
    }
    return window.count - (counts.values.max() ?? 0)
}

print(repaintCost("QQXQQ"))
print(repaintCost("QQXQQYQQ"))
print(repaintCost("ABCDE"))
