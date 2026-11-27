// Generated from src/dsa/content/lessons/strings-basic/str-reverse-words.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reverseEachWord(_ text: String) -> String {
    text.split(separator: " ", omittingEmptySubsequences: false)
        .map { String($0.reversed()) }
        .joined(separator: " ")
}

print(reverseEachWord("Swift is fun"))
print("[" + reverseEachWord("two  spaces") + "]")
