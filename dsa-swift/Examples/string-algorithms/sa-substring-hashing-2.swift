// Generated from src/dsa/content/lessons/string-algorithms/sa-substring-hashing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mersenne: UInt64 = (1 << 61) - 1
func mulMod(_ a: UInt64, _ b: UInt64) -> UInt64 {
    let (high, low) = a.multipliedFullWidth(by: b)
    let sum = ((high << 3) | (low >> 61)) + (low & mersenne)
    return sum >= mersenne ? sum - mersenne : sum
}

struct SubstringHashes {
    private var prefix: [UInt64], power: [UInt64]
    init(_ s: [UInt8], base: UInt64) {
        prefix = [UInt64](repeating: 0, count: s.count + 1)
        power = [UInt64](repeating: 1, count: s.count + 1)
        for i in s.indices {
            let next = mulMod(prefix[i], base) + UInt64(s[i])
            prefix[i + 1] = next >= mersenne ? next - mersenne : next
            power[i + 1] = mulMod(power[i], base)
        }
    }
    func hash(_ a: Int, _ b: Int) -> UInt64 {
        let shifted = mulMod(prefix[a], power[b - a])
        return prefix[b] >= shifted ? prefix[b] - shifted : prefix[b] + mersenne - shifted
    }
}

let text = Array("mississippi".utf8)
let hashes = SubstringHashes(text, base: 1_000_003)

// The longest common prefix of the suffixes at i and j, by binary search on its length
func lcp(_ i: Int, _ j: Int) -> Int {
    var low = 0, high = text.count - max(i, j)     // the answer is in low...high
    while low < high {
        let mid = (low + high + 1) / 2
        if hashes.hash(i, i + mid) == hashes.hash(j, j + mid) {
            low = mid                               // the first mid characters agree
        } else {
            high = mid - 1
        }
    }
    return low
}

// Compare two suffixes: skip their common prefix, then look at one character
func suffixPrecedes(_ i: Int, _ j: Int) -> Bool {
    let common = lcp(i, j)
    if i + common == text.count { return j + common < text.count }   // i ran out first
    if j + common == text.count { return false }
    return text[i + common] < text[j + common]
}

print(lcp(1, 4), lcp(2, 5), lcp(0, 1))             // issi…/issi…, ssi…/ssi…, m…/i…
let sa = text.indices.sorted(by: suffixPrecedes)
print(sa)
print(sa == text.indices.sorted { text[$0...].lexicographicallyPrecedes(text[$1...]) })
