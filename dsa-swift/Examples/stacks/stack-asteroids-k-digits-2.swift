// Generated from src/dsa/content/lessons/stacks/stack-asteroids-k-digits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func smallest(_ digits: String, removing k: Int) -> String {
    var kept: [Character] = []
    var removalsLeft = k
    for digit in digits {
        while removalsLeft > 0, let last = kept.last, last > digit {
            kept.removeLast()                   // a smaller digit can move left: drop the bigger one
            removalsLeft -= 1
        }
        kept.append(digit)
    }
    kept.removeLast(min(removalsLeft, kept.count))   // still owe removals: take them from the end
    let trimmed = kept.drop { $0 == "0" }
    return trimmed.isEmpty ? "0" : String(trimmed)
}

for (digits, k) in [("1432219", 3), ("10200", 1), ("10", 2), ("12345", 2), ("4321", 2)] {
    print("\(digits) removing \(k) -> \(smallest(digits, removing: k))")
}
