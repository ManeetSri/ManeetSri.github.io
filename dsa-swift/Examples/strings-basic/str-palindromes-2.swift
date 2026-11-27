// Generated from src/dsa/content/lessons/strings-basic/str-palindromes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestPalindromeBrute(_ text: String) -> String {
    let chars = Array(text)
    var best = ""
    for start in chars.indices {
        for end in start..<chars.count {
            let piece = Array(chars[start...end])
            if piece.count > best.count && piece == piece.reversed() {
                best = String(piece)
            }
        }
    }
    return best
}

print(longestPalindromeBrute("abracadabra"))
print(longestPalindromeBrute("banana"))
