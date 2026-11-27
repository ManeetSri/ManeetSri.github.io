// Generated from src/dsa/content/lessons/strings-basic/str-compression.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func compressIfShorter(_ text: String) -> String {
    let chars = Array(text)
    var result = ""
    var i = 0
    while i < chars.count {
        var j = i
        while j < chars.count && chars[j] == chars[i] {
            j += 1
        }
        result.append(chars[i])
        if j - i > 1 {
            result += String(j - i)
        }
        i = j
    }
    return result.count < chars.count ? result : text
}

print(compressIfShorter("aaabccdddd"))
print(compressIfShorter("abc"))
print(compressIfShorter("aabb"))
