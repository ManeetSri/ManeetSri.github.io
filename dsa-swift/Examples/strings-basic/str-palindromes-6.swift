// Generated from src/dsa/content/lessons/strings-basic/str-palindromes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countPalindromes(_ text: String) -> Int {
    let chars = Array(text)
    var count = 0
    func expand(_ low: Int, _ high: Int) {
        var low = low
        var high = high
        while low >= 0 && high < chars.count && chars[low] == chars[high] {
            count += 1                  // chars[low...high] is a palindrome
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

print(countPalindromes("abc"))
print(countPalindromes("aaa"))
print(countPalindromes("abba"))
