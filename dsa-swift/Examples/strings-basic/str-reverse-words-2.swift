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

var chars = Array("the sky is blue")
reverse(&chars, from: 0, to: chars.count - 1)
print(String(chars))

var start = 0
for index in 0...chars.count {
    if index == chars.count || chars[index] == " " {
        reverse(&chars, from: start, to: index - 1)     // one word: start...index - 1
        start = index + 1
    }
}
print(String(chars))
