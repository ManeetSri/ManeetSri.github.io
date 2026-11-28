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

// Where does some substring of this length occur twice? nil if none does.
func repeatStart(_ length: Int, _ text: [UInt8], _ hashes: SubstringHashes) -> Int? {
    var seen = Set<UInt64>()
    for start in 0...(text.count - length) {
        if !seen.insert(hashes.hash(start, start + length)).inserted {
            return start
        }
    }
    return nil
}

// If some length repeats, every shorter length does too, so binary search for the longest
func longestRepeat(_ word: String) -> String {
    let text = Array(word.utf8)
    let hashes = SubstringHashes(text, base: 1_000_003)
    var low = 0, high = text.count - 1                  // the answer is in low...high
    while low < high {
        let mid = (low + high + 1) / 2
        if repeatStart(mid, text, hashes) != nil { low = mid } else { high = mid - 1 }
    }
    guard low > 0, let start = repeatStart(low, text, hashes) else { return "" }
    return String(decoding: text[start..<(start + low)], as: UTF8.self)
}

for word in ["banana", "abracadabra", "mississippi", "abcd", "aaaa"] {
    print(word, "\"\(longestRepeat(word))\"")
}
