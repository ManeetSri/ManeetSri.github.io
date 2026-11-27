// Generated from src/dsa/content/lessons/strings-basic/str-isomorphic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func followsPattern(_ pattern: String, _ sentence: String) -> Bool {
    let letters = Array(pattern)
    let words = sentence.split(separator: " ").map(String.init)
    guard letters.count == words.count else { return false }
    var wordFor: [Character: String] = [:]
    var letterFor: [String: Character] = [:]
    for (letter, word) in zip(letters, words) {
        if let mapped = wordFor[letter], mapped != word { return false }
        if let mapped = letterFor[word], mapped != letter { return false }
        wordFor[letter] = word
        letterFor[word] = letter
    }
    return true
}

print(followsPattern("xyyx", "sun moon moon sun"))
print(followsPattern("xyyx", "sun moon moon star"))
print(followsPattern("xy", "sun sun"))
print(followsPattern("xyz", "red green"))
