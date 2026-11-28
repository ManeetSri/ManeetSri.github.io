// Reference solution: Polynomial string hash. Horner's rule, taking the remainder after every step
// so the running value stays below the modulus and nothing overflows. O(n) time for n scalars,
// O(1) space; bucketSizes is O(total length of the words + bucketCount).

public enum PolynomialStringHash {
    public static func hash(of text: String, base: Int, modulus: Int) -> Int {
        var hash = 0
        for scalar in text.unicodeScalars {
            hash = (hash * base + Int(scalar.value)) % modulus
        }
        return hash
    }

    public static func bucketSizes(for words: [String], bucketCount: Int) -> [Int] {
        var sizes = Array(repeating: 0, count: bucketCount)
        for word in words {
            sizes[hash(of: word, base: 31, modulus: bucketCount)] += 1
        }
        return sizes
    }
}
