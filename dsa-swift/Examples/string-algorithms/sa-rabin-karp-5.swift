// Generated from src/dsa/content/lessons/string-algorithms/sa-rabin-karp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mersenne: UInt64 = (1 << 61) - 1
func mulMod(_ a: UInt64, _ b: UInt64) -> UInt64 {
    let (high, low) = a.multipliedFullWidth(by: b)
    let sum = ((high << 3) | (low >> 61)) + (low & mersenne)
    return sum >= mersenne ? sum - mersenne : sum
}
func addMod(_ a: UInt64, _ b: UInt64) -> UInt64 {
    let sum = a + b                                 // both below 2^61, so no overflow
    return sum >= mersenne ? sum - mersenne : sum
}
func subMod(_ a: UInt64, _ b: UInt64) -> UInt64 {
    a >= b ? a - b : a + mersenne - b               // never goes below zero, which would trap
}

let base: UInt64 = 1_000_003                        // real code: UInt64.random(in: 256..<mersenne)

func hash(_ s: ArraySlice<UInt8>) -> UInt64 {
    s.reduce(0) { addMod(mulMod($0, base), UInt64($1)) }
}

// Every occurrence of several patterns of the same length, in one pass over the text
func findAll(_ patterns: [String], in text: String) -> [String: [Int]] {
    let t = Array(text.utf8)
    let m = patterns[0].utf8.count
    var wanted: [UInt64: [String]] = [:]             // hash → the patterns with that hash
    for p in patterns { wanted[hash(ArraySlice(p.utf8)), default: []].append(p) }
    var found: [String: [Int]] = [:]
    guard m <= t.count else { return found }
    var high: UInt64 = 1                            // base^(m - 1)
    for _ in 1..<m { high = mulMod(high, base) }
    var h = hash(t[0..<m])
    for start in 0...(t.count - m) {
        if start > 0 {
            h = subMod(h, mulMod(UInt64(t[start - 1]), high))
            h = addMod(mulMod(h, base), UInt64(t[start + m - 1]))
        }
        for p in wanted[h] ?? [] where t[start..<(start + m)].elementsEqual(p.utf8) {
            found[p, default: []].append(start)
        }
    }
    return found
}

let text = "the cat and the dog saw an owl; the cat ran"
let found = findAll(["cat", "dog", "owl", "eel"], in: text)
for word in ["cat", "dog", "owl", "eel"] {
    print(word, found[word] ?? [])
}
