// Generated from src/dsa/content/lessons/tries/trie-concept.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["car", "cat", "cart", "care", "card", "dog", "do", "dot"]
var prefixes = Set<String>()
for word in words {
    for length in 1...word.count {
        prefixes.insert(String(word.prefix(length)))
    }
}
print("letters:", words.reduce(0) { $0 + $1.count })
print("nodes below the root:", prefixes.count)
