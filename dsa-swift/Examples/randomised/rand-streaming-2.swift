// Generated from src/dsa/content/lessons/randomised/rand-streaming.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Misra–Gries: every item that makes up more than 1/k of a stream, with only k - 1 counters
func frequentCandidates(_ stream: [String], k: Int) -> [String: Int] {
    var counters: [String: Int] = [:]
    for item in stream {
        if counters[item] != nil {
            counters[item]! += 1                  // already counted: one more
        } else if counters.count < k - 1 {
            counters[item] = 1                    // a free counter
        } else {
            for key in Array(counters.keys) {     // no room: every counter loses one,
                counters[key]! -= 1               // and the new item is cancelled out too
                if counters[key] == 0 { counters[key] = nil }
            }
        }
    }
    return counters
}

let base = ["swift", "rust", "swift", "go", "swift", "kotlin", "rust", "swift", "zig", "rust", "swift", "c"]
var stream: [String] = []
for _ in 0..<1_000 { stream += base }              // 12,000 words: swift 5/12, rust 3/12

let candidates = frequentCandidates(stream, k: 5)   // at most 4 counters
for word in candidates.keys.sorted() {
    let exact = stream.filter { $0 == word }.count  // a second pass confirms the real count
    let verdict = exact * 5 > stream.count ? "more than 1/5" : "not frequent"
    print(word, "counter \(candidates[word]!), exact \(exact): \(verdict)")
}
