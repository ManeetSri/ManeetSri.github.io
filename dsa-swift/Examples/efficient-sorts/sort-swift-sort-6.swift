// Generated from src/dsa/content/lessons/efficient-sorts/sort-swift-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Computing an expensive key inside the comparison repeats the work on every comparison
var keyComputations = 0

func sortKey(_ word: String) -> String {
    keyComputations += 1
    return word.lowercased()
}

let words = (0..<1_000).map { "Word\(($0 * 7_919) % 1_000)" }

let slow = words.sorted { sortKey($0) < sortKey($1) }
print("inside the comparison: \(keyComputations) key computations")

keyComputations = 0
let fast = words
    .map { (key: sortKey($0), word: $0) }    // compute each key once
    .sorted { $0.key < $1.key }
    .map { $0.word }
print("computed once each: \(keyComputations) key computations")
print(slow == fast)
