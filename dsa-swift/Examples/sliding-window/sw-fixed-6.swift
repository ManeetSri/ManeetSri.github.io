// Generated from src/dsa/content/lessons/sliding-window/sw-fixed.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func maxVowels(in text: String, k: Int) -> Int {
    let chars = Array(text)
    let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
    var count = 0
    var best = 0
    for right in 0..<chars.count {
        if vowels.contains(chars[right]) {
            count += 1
        }
        if right >= k && vowels.contains(chars[right - k]) {
            count -= 1
        }
        if right >= k - 1 {
            best = max(best, count)
        }
    }
    return best
}

print(maxVowels(in: "beautifulday", k: 4))
print(maxVowels(in: "rhythm", k: 3))
