// Reference solution: Longest stretch shared by two DNA strands. If the strands share a stretch of
// length L, they share one of every shorter length, so binary search on L. To test a length, hash
// every window of that length in the first strand into a set, then look for any window of the second
// strand in it. Prefix hashes modulo the prime 2^61 - 1 give each window's hash in O(1); the
// multiplication goes through the full 128-bit product. Both strands use the same random base, so
// equal stretches get equal hashes and nobody can plan a collision. O((n + m) log(min(n, m))) time.

public enum SharedDNAStretch {
    public static func longest(_ first: String, _ second: String) -> Int {
        let a = Array(first.utf8), b = Array(second.utf8)
        let base = UInt64.random(in: 256..<modulus)
        let hashesA = PrefixHashes(a, base: base)
        let hashesB = PrefixHashes(b, base: base)

        func shared(_ length: Int) -> Bool {
            var seen = Set<UInt64>(minimumCapacity: a.count - length + 1)
            for start in 0...(a.count - length) {
                seen.insert(hashesA.hash(start, start + length))
            }
            for start in 0...(b.count - length) where seen.contains(hashesB.hash(start, start + length)) {
                return true
            }
            return false
        }

        var low = 0, high = min(a.count, b.count)       // the answer is in low...high
        while low < high {
            let mid = (low + high + 1) / 2
            if shared(mid) { low = mid } else { high = mid - 1 }
        }
        return low
    }

    static let modulus: UInt64 = (1 << 61) - 1

    static func mulMod(_ x: UInt64, _ y: UInt64) -> UInt64 {
        let (high, low) = x.multipliedFullWidth(by: y)
        let sum = ((high << 3) | (low >> 61)) + (low & modulus)
        return sum >= modulus ? sum - modulus : sum
    }

    struct PrefixHashes {
        private var prefix: [UInt64], power: [UInt64]

        init(_ s: [UInt8], base: UInt64) {
            prefix = [UInt64](repeating: 0, count: s.count + 1)
            power = [UInt64](repeating: 1, count: s.count + 1)
            for i in s.indices {
                let value = SharedDNAStretch.mulMod(prefix[i], base) + UInt64(s[i])
                prefix[i + 1] = value >= SharedDNAStretch.modulus ? value - SharedDNAStretch.modulus : value
                power[i + 1] = SharedDNAStretch.mulMod(power[i], base)
            }
        }

        /// The hash of s[from..<to], in O(1).
        func hash(_ from: Int, _ to: Int) -> UInt64 {
            let shifted = SharedDNAStretch.mulMod(prefix[from], power[to - from])
            return prefix[to] >= shifted ? prefix[to] - shifted : prefix[to] + SharedDNAStretch.modulus - shifted
        }
    }
}
