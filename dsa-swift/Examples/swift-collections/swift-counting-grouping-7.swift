// Generated from src/dsa/content/lessons/swift-collections/swift-counting-grouping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["apple", "avocado", "banana", "blueberry", "cherry", "apricot"]
var byLetter: [Character: [String]] = [:]

for word in words {
    if let first = word.first {
        byLetter[first, default: []].append(word)
    }
}

for letter in byLetter.keys.sorted() {
    print(letter, byLetter[letter] ?? [])
}
