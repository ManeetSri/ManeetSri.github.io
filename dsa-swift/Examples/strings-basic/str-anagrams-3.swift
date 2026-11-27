// Generated from src/dsa/content/lessons/strings-basic/str-anagrams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func groupAnagrams(_ words: [String]) -> [[String]] {
    var groupIndex: [String: Int] = [:]
    var result: [[String]] = []
    for word in words {
        let key = String(word.sorted())
        if let index = groupIndex[key] {
            result[index].append(word)
        } else {
            groupIndex[key] = result.count      // the new group's position
            result.append([word])
        }
    }
    return result
}

print(groupAnagrams(["stone", "night", "notes", "thing", "onset", "tab", "bat"]))
print(groupAnagrams(["a", "a", ""]))
