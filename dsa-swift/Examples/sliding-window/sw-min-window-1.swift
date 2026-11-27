// Generated from src/dsa/content/lessons/sliding-window/sw-min-window.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minWindow(_ text: String, _ pattern: String) -> String {
    let t = Array(text.utf8)
    let p = Array(pattern.utf8)
    guard !p.isEmpty else { return "" }
    var need = [Int](repeating: 0, count: 128)
    for byte in p {
        need[Int(byte)] += 1
    }
    let required = need.filter { $0 > 0 }.count   // distinct characters to cover
    var have = [Int](repeating: 0, count: 128)
    var satisfied = 0
    var left = 0
    var bestStart = 0
    var bestLength = Int.max
    for right in 0..<t.count {
        let entering = Int(t[right])
        have[entering] += 1
        if need[entering] > 0 && have[entering] == need[entering] {
            satisfied += 1                         // reached exactly what's needed
        }
        while satisfied == required {
            if right - left + 1 < bestLength {
                bestLength = right - left + 1
                bestStart = left
            }
            let leaving = Int(t[left])
            if need[leaving] > 0 && have[leaving] == need[leaving] {
                satisfied -= 1                     // about to drop below what's needed
            }
            have[leaving] -= 1
            left += 1
        }
    }
    guard bestLength != Int.max else { return "" }
    return String(decoding: t[bestStart..<bestStart + bestLength], as: UTF8.self)
}

print(minWindow("BANANABREAD", "ABD"))
print(minWindow("xaybzaxb", "aab"))
print(minWindow("a", "A").isEmpty)
