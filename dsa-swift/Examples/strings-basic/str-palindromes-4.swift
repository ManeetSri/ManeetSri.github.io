// Generated from src/dsa/content/lessons/strings-basic/str-palindromes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestPalindrome(_ text: String) -> String {
    let chars = Array(text)
    var bestStart = 0
    var bestLength = 0

    func expand(_ low: Int, _ high: Int) {
        var low = low
        var high = high
        while low >= 0 && high < chars.count && chars[low] == chars[high] {
            low -= 1
            high += 1
        }
        if high - low - 1 > bestLength {
            bestLength = high - low - 1
            bestStart = low + 1
        }
    }

    for centre in chars.indices {
        expand(centre, centre)          // odd length
        expand(centre, centre + 1)      // even length
    }
    return String(chars[bestStart..<bestStart + bestLength])
}

print(longestPalindrome("abracadabra"))
print(longestPalindrome("noonday"))
print(longestPalindrome("banana"))
print(longestPalindrome("ab"))
print(longestPalindrome("").isEmpty)
