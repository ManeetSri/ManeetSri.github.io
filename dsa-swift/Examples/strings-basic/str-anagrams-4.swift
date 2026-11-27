// Generated from src/dsa/content/lessons/strings-basic/str-anagrams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func letterCounts(_ word: String) -> [Int] {
    var counts = [Int](repeating: 0, count: 26)
    for byte in word.utf8 {
        counts[Int(byte - UInt8(ascii: "a"))] += 1
    }
    return counts
}

print(letterCounts("banana")[0..<3])
print(letterCounts("stone") == letterCounts("notes"))
print(letterCounts("aab") == letterCounts("abb"))

var groupIndex: [[Int]: Int] = [:]
var result: [[String]] = []
for word in ["listen", "google", "silent", "enlist", "banana"] {
    let key = letterCounts(word)
    if let index = groupIndex[key] {
        result[index].append(word)
    } else {
        groupIndex[key] = result.count
        result.append([word])
    }
}
print(result)
