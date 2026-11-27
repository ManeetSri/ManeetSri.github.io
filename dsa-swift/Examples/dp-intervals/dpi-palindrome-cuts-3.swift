// Generated from src/dsa/content/lessons/dp-intervals/dpi-palindrome-cuts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fewestCutsCompact(_ text: String) -> Int {
    let s = Array(text)
    let n = s.count
    guard n > 0 else { return 0 }
    var cuts = Array(0..<n)                        // worst case: cut before every letter but the first
    for centre in 0..<n {
        for (startLeft, startRight) in [(centre, centre), (centre, centre + 1)] {   // odd, then even length
            var l = startLeft
            var r = startRight
            while l >= 0 && r < n && s[l] == s[r] {
                cuts[r] = min(cuts[r], l == 0 ? 0 : cuts[l - 1] + 1)
                l -= 1
                r += 1
            }
        }
    }
    return cuts[n - 1]
}

print(fewestCutsCompact("noonabbad"), fewestCutsCompact("racecarannakayak"), fewestCutsCompact("abcd"))
