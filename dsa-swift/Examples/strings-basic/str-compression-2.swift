// Generated from src/dsa/content/lessons/strings-basic/str-compression.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func decode(_ encoded: String) -> String {
    var result = ""
    var current: Character? = nil
    var count = 0
    for ch in encoded {
        if let digit = ch.wholeNumberValue {
            count = count * 10 + digit
        } else {
            if let letter = current {
                result += String(repeating: letter, count: count)
            }
            current = ch
            count = 0
        }
    }
    if let letter = current {
        result += String(repeating: letter, count: count)   // the last run
    }
    return result
}

print(decode("a3b1c2d4"))
print(decode("z12y1"))
print(decode("").isEmpty)
