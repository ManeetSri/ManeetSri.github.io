// Generated from src/dsa/content/lessons/strings-basic/str-reverse-words.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reverse(_ chars: inout [Character], from start: Int, to end: Int) {
    var left = start
    var right = end
    while left < right {
        chars.swapAt(left, right)
        left += 1
        right -= 1
    }
}

func reverseWords(_ text: String) -> String {
    var chars = Array(text)

    // 1. Squeeze: one space between words, none at the ends
    var write = 0
    var read = 0
    while read < chars.count {
        if chars[read] == " " {
            read += 1
            continue
        }
        if write > 0 {
            chars[write] = " "              // separator before every word but the first
            write += 1
        }
        while read < chars.count && chars[read] != " " {
            chars[write] = chars[read]
            write += 1
            read += 1
        }
    }
    chars.removeLast(chars.count - write)

    // 2. Reverse everything, then 3. reverse each word
    reverse(&chars, from: 0, to: chars.count - 1)
    var start = 0
    for index in 0...chars.count where index == chars.count || chars[index] == " " {
        reverse(&chars, from: start, to: index - 1)
        start = index + 1
    }
    return String(chars)
}

print("[" + reverseWords("  the sky   is blue ") + "]")
print("[" + reverseWords("one") + "]")
print("[" + reverseWords("   ") + "]")
