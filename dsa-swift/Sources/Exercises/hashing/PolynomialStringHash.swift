// Problem: Polynomial string hash (M24 · Hash functions)

public enum PolynomialStringHash {
    /// Returns the polynomial hash of `text`: start from 0 and, for each Unicode scalar value c,
    /// set h = (h × base + c) % modulus.
    public static func hash(of text: String, base: Int, modulus: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter PolynomialStringHashTests
        return 0
    }

    /// Puts each word in bucket `hash(of: word, base: 31, modulus: bucketCount)` and returns how
    /// many words landed in each bucket, from bucket 0 to bucket bucketCount - 1.
    public static func bucketSizes(for words: [String], bucketCount: Int) -> [Int] {
        return []
    }
}
