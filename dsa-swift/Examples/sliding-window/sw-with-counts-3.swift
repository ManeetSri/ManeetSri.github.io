// Generated from src/dsa/content/lessons/sliding-window/sw-with-counts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func anagramTrace(_ pattern: String, in text: String) {
    let p = Array(pattern.utf8)
    let t = Array(text.utf8)
    let m = p.count
    let a = UInt8(ascii: "a")
    var need = [Int](repeating: 0, count: 26)
    var have = [Int](repeating: 0, count: 26)
    for byte in p {
        need[Int(byte - a)] += 1
    }
    var matches = 0
    for slot in 0..<26 where need[slot] == 0 {
        matches += 1
    }
    print("before any letters: matches \(matches)")

    func change(_ slot: Int, by delta: Int) {
        if have[slot] == need[slot] { matches -= 1 }   // it agreed before
        have[slot] += delta
        if have[slot] == need[slot] { matches += 1 }   // it agrees now
    }

    for right in 0..<t.count {
        change(Int(t[right] - a), by: 1)
        if right >= m {
            change(Int(t[right - m] - a), by: -1)
        }
        if right >= m - 1 {
            let window = String(decoding: t[(right - m + 1)...right], as: UTF8.self)
            print(window, "matches", matches, matches == 26 ? "anagram" : "")
        }
    }
}

anagramTrace("tops", in: "whatspot")
