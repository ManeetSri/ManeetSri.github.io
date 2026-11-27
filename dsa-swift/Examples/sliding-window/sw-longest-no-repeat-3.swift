// Generated from src/dsa/content/lessons/sliding-window/sw-longest-no-repeat.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countOperations(_ text: String) -> (inserts: Int, removes: Int, best: Int) {
    let chars = Array(text)
    var seen = Set<Character>()
    var left = 0
    var best = 0
    var inserts = 0
    var removes = 0
    for right in 0..<chars.count {
        while seen.contains(chars[right]) {
            seen.remove(chars[left])
            removes += 1
            left += 1
        }
        seen.insert(chars[right])
        inserts += 1
        best = max(best, right - left + 1)
    }
    return (inserts, removes, best)
}

let letters = Array("abcdefghijklmnopqrstuvwxyz")
let text = String((0..<100_000).map { letters[$0 % 26] })
print(countOperations(text))
