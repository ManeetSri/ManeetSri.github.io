// Generated from src/dsa/content/lessons/string-algorithms/sa-substring-hashing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mersenne: UInt64 = (1 << 61) - 1
func mulMod(_ a: UInt64, _ b: UInt64) -> UInt64 {
    let (high, low) = a.multipliedFullWidth(by: b)
    let sum = ((high << 3) | (low >> 61)) + (low & mersenne)
    return sum >= mersenne ? sum - mersenne : sum
}

// Prefix hashes and powers: after O(n) preparation, the hash of any slice in O(1)
struct SubstringHashes {
    private var prefix: [UInt64]                    // prefix[i] = hash of s[0..<i]
    private var power: [UInt64]                     // power[i] = base^i
    init(_ s: [UInt8], base: UInt64) {
        prefix = [UInt64](repeating: 0, count: s.count + 1)
        power = [UInt64](repeating: 1, count: s.count + 1)
        for i in s.indices {
            let next = mulMod(prefix[i], base) + UInt64(s[i])
            prefix[i + 1] = next >= mersenne ? next - mersenne : next
            power[i + 1] = mulMod(power[i], base)
        }
    }

    // The hash of s[a..<b]: prefix[b] minus prefix[a] shifted up by b - a places
    func hash(_ a: Int, _ b: Int) -> UInt64 {
        let shifted = mulMod(prefix[a], power[b - a])
        return prefix[b] >= shifted ? prefix[b] - shifted : prefix[b] + mersenne - shifted
    }
}

let text = Array("abracadabra".utf8)
let hashes = SubstringHashes(text, base: 1_000_003)
print(hashes.hash(0, 4) == hashes.hash(7, 11))     // abra and abra
print(hashes.hash(0, 1) == hashes.hash(3, 4))      // a and a
print(hashes.hash(1, 4) == hashes.hash(8, 11))     // bra and bra
print(hashes.hash(0, 4) == hashes.hash(1, 5))      // abra and brac
let whole = SubstringHashes(Array("abra".utf8), base: 1_000_003)
print(whole.hash(0, 4) == hashes.hash(7, 11))      // the same text in another string, the same hash
