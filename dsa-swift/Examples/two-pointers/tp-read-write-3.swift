// Generated from src/dsa/content/lessons/two-pointers/tp-read-write.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isSubsequence(_ pattern: String, of text: String) -> Bool {
    let wanted = Array(pattern)
    var next = 0                        // the next character of pattern to find
    for character in text where next < wanted.count && character == wanted[next] {
        next += 1
    }
    return next == wanted.count
}

print(isSubsequence("wit", of: "swift"))
print(isSubsequence("fit", of: "swift"))
print(isSubsequence("", of: "swift"))
