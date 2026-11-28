// Generated from src/dsa/content/lessons/math-basics/math-pigeonhole.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func hasAllUniqueLetters(_ word: String) -> Bool {
    let letters = Array(word.utf8)
    if letters.count > 26 {
        return false
    }
    var seen = Array(repeating: false, count: 26)
    for byte in letters {
        let index = Int(byte - 97)
        if seen[index] {
            return false
        }
        seen[index] = true
    }
    return true
}

print(hasAllUniqueLetters("swift"), hasAllUniqueLetters("hello"))
print(hasAllUniqueLetters("abcdefghijklmnopqrstuvwxyza"))
