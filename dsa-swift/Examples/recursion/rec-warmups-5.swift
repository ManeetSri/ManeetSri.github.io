// Generated from src/dsa/content/lessons/recursion/rec-warmups.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reverse(_ chars: inout [Character], _ low: Int, _ high: Int) {
    if low >= high {
        return                          // zero or one character in the middle
    }
    chars.swapAt(low, high)
    reverse(&chars, low + 1, high - 1)
}

func reversed(_ text: String) -> String {
    var chars = Array(text)
    reverse(&chars, 0, chars.count - 1)
    return String(chars)
}

print(reversed("swift"))
print(reversed("café"))
print(reversed("a"))
print(reversed("") == "")
