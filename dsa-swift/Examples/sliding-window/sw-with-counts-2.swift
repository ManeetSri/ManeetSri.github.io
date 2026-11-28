// Generated from src/dsa/content/lessons/sliding-window/sw-with-counts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func containsAnagram(_ pattern: String, in text: String) -> Bool {
    let p = Array(pattern.utf8)
    let t = Array(text.utf8)
    let m = p.count
    guard m <= t.count else { return false }
    let a = UInt8(ascii: "a")
    var need = [Int](repeating: 0, count: 26)
    var have = [Int](repeating: 0, count: 26)
    for byte in p {
        need[Int(byte - a)] += 1
    }
    for right in 0..<t.count {
        have[Int(t[right] - a)] += 1             // entering
        if right >= m {
            have[Int(t[right - m] - a)] -= 1     // leaving
        }
        if right >= m - 1 && have == need {
            return true
        }
    }
    return false
}

print(containsAnagram("tops", in: "whatspot"))
print(containsAnagram("tops", in: "stoop"))
print(containsAnagram("ab", in: "a"))
