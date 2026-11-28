// Generated from src/dsa/content/lessons/dp-strings/dps-distinct-subsequences.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let modulus = 1_000_000_007

/// How many different non-empty strings are subsequences of `text`?
func distinctSubsequences(_ text: String) -> Int {
    var total = 1                                   // the empty subsequence, removed at the end
    var before: [Character: Int] = [:]              // total just before the letter's last use
    for letter in text {
        let previous = total
        total = (total * 2) % modulus               // every old subsequence, with and without letter
        if let repeated = before[letter] {
            total = (total - repeated + modulus) % modulus   // these were counted last time
        }
        before[letter] = previous
    }
    return (total - 1 + modulus) % modulus
}

print(distinctSubsequences("abc"))
print(distinctSubsequences("aba"))
print(distinctSubsequences("aaa"))
print(distinctSubsequences(String(repeating: "swift", count: 200)))
