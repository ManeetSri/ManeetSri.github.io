// Generated from src/dsa/content/lessons/greedy/greedy-partition-labels.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func letterZones(_ text: String) -> [String] {
    let letters = Array(text)
    var last: [Character: Int] = [:]
    for (i, letter) in letters.enumerated() {
        last[letter] = i                          // later positions overwrite earlier ones
    }
    var parts: [String] = []
    var start = 0
    var end = 0                                   // the piece can't end before this index
    for (i, letter) in letters.enumerated() {
        end = max(end, last[letter]!)
        if i == end {                             // every letter so far has finished: cut here
            parts.append(String(letters[start...i]))
            start = i + 1
        }
    }
    return parts
}

print(letterZones("abacbdedfghgih"))
print(letterZones("abcabc"))
print(letterZones("xyz"))
