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

var letters = Array("abcdefg")
reverse(&letters, from: 0, to: 1)                    // "ba" + "cdefg"
reverse(&letters, from: 2, to: letters.count - 1)    // "ba" + "gfedc"
reverse(&letters, from: 0, to: letters.count - 1)    // "cdefg" + "ab"
print(String(letters))
