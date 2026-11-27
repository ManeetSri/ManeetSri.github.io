// Generated from src/dsa/content/lessons/linear-sorts/sort-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sortedLetters(_ word: String) -> String {
    var counts = [Int](repeating: 0, count: 26)
    for letter in word {
        counts[Int(letter.asciiValue! - 97)] += 1     // lowercase a to z only
    }
    var result = ""
    for slot in 0..<26 where counts[slot] > 0 {
        let letter = Character(UnicodeScalar(UInt8(97 + slot)))
        result += String(repeating: letter, count: counts[slot])
    }
    return result
}

print(sortedLetters("banana"))
print(sortedLetters("listen") == sortedLetters("silent"))
