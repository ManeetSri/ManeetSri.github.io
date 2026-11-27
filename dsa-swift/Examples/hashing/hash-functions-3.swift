// Generated from src/dsa/content/lessons/hashing/hash-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func polynomialHash(_ word: String, modulus: Int) -> Int {
    var hash = 0
    for scalar in word.unicodeScalars {
        hash = (hash * 31 + Int(scalar.value)) % modulus
    }
    return hash
}

let words = ["stop", "pots", "tops", "spot", "opts", "post"]
for word in words {
    print(word, polynomialHash(word, modulus: 11))
}
