// Generated from src/dsa/content/lessons/string-algorithms/sa-rabin-karp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Rabin–Karp with a modulus that fits comfortably in Int
func rabinKarp(_ pattern: [UInt8], in text: [UInt8], modulus: Int) -> (matches: [Int], hashHits: Int) {
    let m = pattern.count, n = text.count
    guard m > 0, m <= n else { return ([], 0) }
    let base = 131
    var high = 1                                    // base^(m - 1) % modulus
    for _ in 1..<m { high = high * base % modulus }
    var patternHash = 0, windowHash = 0
    for k in 0..<m {
        patternHash = (patternHash * base + Int(pattern[k])) % modulus
        windowHash = (windowHash * base + Int(text[k])) % modulus
    }
    var matches: [Int] = []
    var hashHits = 0
    for start in 0...(n - m) {
        if start > 0 {                              // roll: remove text[start - 1], add text[start + m - 1]
            windowHash = (windowHash - Int(text[start - 1]) * high % modulus + modulus) % modulus
            windowHash = (windowHash * base + Int(text[start + m - 1])) % modulus
        }
        if windowHash == patternHash {
            hashHits += 1
            if text[start..<(start + m)].elementsEqual(pattern) {   // verify: hashes can collide
                matches.append(start)
            }
        }
    }
    return (matches, hashHits)
}

// 5,000 made-up lowercase letters, the same every run
var seed = 63
var text: [UInt8] = []
for _ in 0..<5_000 {
    seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
    text.append(97 + UInt8((seed >> 16) % 26))
}
let pattern = Array(text[1234..<1240])
print("pattern:", String(decoding: pattern, as: UTF8.self))
for modulus in [101, 1_000_000_007] {
    let result = rabinKarp(pattern, in: text, modulus: modulus)
    print("modulus \(modulus): matches \(result.matches), hash hits \(result.hashHits)")
}
print(rabinKarp(Array("aa".utf8), in: Array("aaaa".utf8), modulus: 1_000_000_007).matches)
