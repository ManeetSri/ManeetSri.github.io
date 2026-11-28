// Generated from src/dsa/content/lessons/swift-collections/swift-counting-grouping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var letterCounts: [Character: Int] = [:]
for letter in "banana" {
    letterCounts[letter, default: 0] += 1
}

for letter in letterCounts.keys.sorted() {
    print(letter, letterCounts[letter] ?? 0)
}
