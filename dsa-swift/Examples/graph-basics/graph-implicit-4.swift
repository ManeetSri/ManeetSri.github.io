// Generated from src/dsa/content/lessons/graph-basics/graph-implicit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let dictionary: Set<String> = ["cold", "cord", "card", "ward", "warm", "word", "worm", "bold", "colt", "core"]

func neighbours(of word: String) -> [String] {
    var letters = Array(word)
    var result: [String] = []
    for index in letters.indices {
        let original = letters[index]
        for letter in "abcdefghijklmnopqrstuvwxyz" where letter != original {
            letters[index] = letter
            let candidate = String(letters)
            if dictionary.contains(candidate) {
                result.append(candidate)
            }
        }
        letters[index] = original                    // put the letter back before the next position
    }
    return result
}

for word in ["cold", "word", "warm"] {
    print(word, "→", neighbours(of: word))
}
