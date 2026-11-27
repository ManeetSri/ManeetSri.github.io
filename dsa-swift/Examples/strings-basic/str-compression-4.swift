// Generated from src/dsa/content/lessons/strings-basic/str-compression.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func compress(_ chars: inout [Character]) -> Int {
    var write = 0
    var read = 0
    while read < chars.count {
        let letter = chars[read]
        var runEnd = read
        while runEnd < chars.count && chars[runEnd] == letter {
            runEnd += 1
        }
        chars[write] = letter
        write += 1
        let length = runEnd - read
        if length > 1 {
            for digit in String(length) {
                chars[write] = digit
                write += 1
            }
        }
        read = runEnd
    }
    return write
}

var chars = Array("aabbbbbbbbbbbbc")
let length = compress(&chars)
print(length, String(chars[0..<length]))
