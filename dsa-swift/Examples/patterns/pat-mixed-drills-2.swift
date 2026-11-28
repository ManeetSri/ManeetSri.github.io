// Generated from src/dsa/content/lessons/patterns/pat-mixed-drills.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Strings of a and b with no letter three times in a row: counted by brute force, then by DP

// Brute force: build every string, keep the valid ones. 2ⁿ strings, so tiny n only.
func countByListing(_ n: Int) -> Int {
    var count = 0
    func build(_ text: [Character]) {
        let k = text.count
        if k >= 3 && text[k - 1] == text[k - 2] && text[k - 2] == text[k - 3] { return }
        if k == n {
            count += 1
            return
        }
        build(text + ["a"])
        build(text + ["b"])
    }
    build([])
    return count
}

// DP: what matters about a valid string is only how long its final run is (1 or 2).
// endsSingle: valid strings ending in a run of 1; endsDouble: ending in a run of 2.
func countByDP(_ n: Int, modulo: Int = 1_000_000_007) -> Int {
    if n <= 1 { return n == 0 ? 1 : 2 }
    var endsSingle = 2                            // "a" and "b"
    var endsDouble = 0
    for _ in 2...n {
        let single = (endsSingle + endsDouble) % modulo   // switch letter: any string can do it
        let double = endsSingle                           // repeat the letter: only after a run of 1
        endsSingle = single
        endsDouble = double
    }
    return (endsSingle + endsDouble) % modulo
}

print((1...8).map(countByListing))
print((1...8).map { countByDP($0) })
print(countByDP(100_000))
