// Generated from src/dsa/content/lessons/hashing/hash-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func letterSum(_ word: String) -> Int {
    var total = 0
    for scalar in word.unicodeScalars {
        total += Int(scalar.value)
    }
    return total
}

let words = ["stop", "pots", "tops", "spot", "opts", "post"]
for word in words {
    print(word, letterSum(word) % 11)
}
