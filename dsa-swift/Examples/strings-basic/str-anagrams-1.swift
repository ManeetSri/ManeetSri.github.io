// Generated from src/dsa/content/lessons/strings-basic/str-anagrams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isAnagram(_ a: String, _ b: String) -> Bool {
    a.sorted() == b.sorted()
}

print(isAnagram("listen", "silent"))
print(isAnagram("aab", "abb"))
