// Generated from src/dsa/content/lessons/strings-basic/str-compression.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func encode(_ text: String) -> String {
    let chars = Array(text)
    var result = ""
    var i = 0
    while i < chars.count {
        var j = i
        while j < chars.count && chars[j] == chars[i] {
            j += 1
        }
        result.append(chars[i])
        result += String(j - i)
        i = j
    }
    return result
}

print(encode("aaabccdddd"))
print(encode(String(repeating: "z", count: 12) + "y"))
