// Generated from src/dsa/design/content/lessons/sd-refactoring/sd-refactoring-change-smells.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Each commit lists the files it touched, as `git log --name-only` prints them
let commits: [[String]] = [
    ["FeedCell.swift", "Router.swift", "ShareText.swift", "Analytics.swift"],
    ["CheckoutViewController.swift"],
    ["FeedCell.swift", "Router.swift", "Analytics.swift"],
    ["CheckoutViewController.swift", "TaxRules.swift"],
    ["FeedCell.swift", "ShareText.swift", "Router.swift"],
    ["CheckoutViewController.swift"],
    ["Router.swift", "FeedCell.swift"],
]

var changes: [String: Int] = [:]
var together: [String: Int] = [:]
for files in commits {
    let sorted = files.sorted()
    for file in sorted {
        changes[file, default: 0] += 1
    }
    for (index, first) in sorted.enumerated() {
        for second in sorted[(index + 1)...] {
            together["\(first) + \(second)", default: 0] += 1
        }
    }
}

// Most first, ties in name order, so the output never depends on dictionary order
func top(_ counts: [String: Int], _ count: Int) -> [(String, Int)] {
    counts.sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
        .prefix(count)
        .map { ($0.key, $0.value) }
}

print("Changed most often:")
for (file, count) in top(changes, 3) {
    print("  \(count)  \(file)")
}
print("Changed together most often:")
for (pair, count) in top(together, 3) {
    print("  \(count)  \(pair)")
}
let wide = commits.filter { $0.count >= 3 }.count
print("Commits touching 3 or more files: \(wide) of \(commits.count)")
