// Generated from src/dsa/content/lessons/sliding-window/sw-min-window.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minWindow(_ text: String, _ pattern: String) -> String {
    let t = Array(text.utf8)
    let p = Array(pattern.utf8)
    guard !p.isEmpty, p.count <= t.count else { return "" }
    var need = [Int](repeating: 0, count: 128)
    for byte in p {
        need[Int(byte)] += 1
    }
    var missing = p.count
    var left = 0
    var bestStart = 0
    var bestLength = Int.max
    for right in 0..<t.count {
        let entering = Int(t[right])
        if need[entering] > 0 {
            missing -= 1
        }
        need[entering] -= 1
        while missing == 0 {
            if right - left + 1 < bestLength {
                bestLength = right - left + 1
                bestStart = left
            }
            let leaving = Int(t[left])
            need[leaving] += 1
            if need[leaving] > 0 {
                missing += 1
            }
            left += 1
        }
    }
    guard bestLength != Int.max else { return "" }
    return String(decoding: t[bestStart..<bestStart + bestLength], as: UTF8.self)
}

print(minWindow("SWIFTLYSWIFT", "WIT"))
print(minWindow("helloworld", "lol"))
print(minWindow("abc", "d").isEmpty)
