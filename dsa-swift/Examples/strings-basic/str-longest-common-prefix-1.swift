// Generated from src/dsa/content/lessons/strings-basic/str-longest-common-prefix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestCommonPrefix(_ words: [String]) -> String {
    guard let first = words.first else { return "" }
    let reference = Array(first)
    let others = words.dropFirst().map { Array($0) }
    for column in 0..<reference.count {
        for chars in others where column == chars.count || chars[column] != reference[column] {
            return String(reference[0..<column])
        }
    }
    return first
}

print(longestCommonPrefix(["interview", "internet", "interval", "internal"]))
print(longestCommonPrefix(["swift", "swiftui", "swiftly"]))
print(longestCommonPrefix(["apple", "banana"]).isEmpty)
print(longestCommonPrefix([]).isEmpty)
