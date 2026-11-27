// Generated from src/dsa/content/lessons/strings-basic/str-longest-common-prefix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestCommonPrefixHorizontal(_ words: [String]) -> String {
    guard let first = words.first else { return "" }
    var prefix = Array(first)
    for word in words.dropFirst() {
        let chars = Array(word)
        var length = 0
        while length < min(prefix.count, chars.count) && prefix[length] == chars[length] {
            length += 1
        }
        prefix.removeLast(prefix.count - length)
        if prefix.isEmpty {
            break
        }
    }
    return String(prefix)
}

print(longestCommonPrefixHorizontal(["interview", "internet", "interval", "internal"]))
print(longestCommonPrefixHorizontal(["abc", "ab", "abcd"]))
