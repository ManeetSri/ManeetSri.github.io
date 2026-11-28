// Generated from src/dsa/content/lessons/strings-basic/str-longest-common-prefix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func verticalComparisons(_ words: [[Character]]) -> Int {
    var count = 0
    for column in 0..<words[0].count {
        for chars in words.dropFirst() {
            count += 1
            if column == chars.count || chars[column] != words[0][column] {
                return count
            }
        }
    }
    return count
}

func horizontalComparisons(_ words: [[Character]]) -> Int {
    var count = 0
    var prefixLength = words[0].count
    for chars in words.dropFirst() {
        var length = 0
        while length < min(prefixLength, chars.count) {
            count += 1
            if chars[length] != words[0][length] {
                break
            }
            length += 1
        }
        prefixLength = length
    }
    return count
}

let long = [Character](repeating: "a", count: 1_000)
let words = [long, long, long, Array("b")]
print(verticalComparisons(words), horizontalComparisons(words))
