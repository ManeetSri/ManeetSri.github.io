// Generated from src/dsa/content/lessons/string-algorithms/sa-substring-hashing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// 100,000 windows of 20 random letters: almost all different. How many hash values do they get?
var seed = 54
var text: [Int] = []
for _ in 0..<100_019 {
    seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
    text.append(97 + (seed >> 16) % 26)
}
let length = 20, base = 131

func windowHashes(modulus: Int) -> Set<Int> {
    var high = 1
    for _ in 1..<length { high = high * base % modulus }
    var h = 0
    for k in 0..<length { h = (h * base + text[k]) % modulus }
    var hashes: Set<Int> = [h]
    for start in 1...(text.count - length) {
        h = (h - text[start - 1] * high % modulus + modulus) % modulus
        h = (h * base + text[start + length - 1]) % modulus
        hashes.insert(h)
    }
    return hashes
}

var windows = Set<ArraySlice<Int>>()
for start in 0...(text.count - length) { windows.insert(text[start..<(start + length)]) }
print("different windows:", windows.count)
print("different hashes mod 1,000,000,007:", windowHashes(modulus: 1_000_000_007).count)
print("different hashes mod 2,147,483,647:", windowHashes(modulus: 2_147_483_647).count)
