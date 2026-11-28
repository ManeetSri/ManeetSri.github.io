// Generated from src/dsa/content/lessons/strings-basic/str-palindromes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func comparisons(_ text: String) -> Int {
    let chars = Array(text.utf8)
    var count = 0
    func expand(_ low: Int, _ high: Int) {
        var low = low
        var high = high
        while low >= 0 && high < chars.count {
            count += 1
            if chars[low] != chars[high] {
                break
            }
            low -= 1
            high += 1
        }
    }
    for centre in chars.indices {
        expand(centre, centre)
        expand(centre, centre + 1)
    }
    return count
}

print(comparisons(String(repeating: "a", count: 1_000)))
print(comparisons(String(repeating: "abcdefghij", count: 100)))
