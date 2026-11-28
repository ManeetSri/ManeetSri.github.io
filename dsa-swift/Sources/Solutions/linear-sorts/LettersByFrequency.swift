// Reference solution: Letters by frequency. Count the letters with 26 slots, then put each letter
// in a bucket indexed by its count, visiting the letters from a to z so every bucket is in
// alphabetical order. Reading the buckets from the highest count down gives the answer.
// O(n + 26) time, O(n) space for the buckets and the result.

public enum LettersByFrequency {
    public static func arrange(_ text: String) -> String {
        let bytes = Array(text.utf8)
        var counts = [Int](repeating: 0, count: 26)
        for byte in bytes {
            counts[Int(byte - 97)] += 1
        }
        // buckets[f] holds the letters (as 0 to 25) that appear exactly f times, a to z
        var buckets = [[Int]](repeating: [], count: bytes.count + 1)
        for letter in 0..<26 where counts[letter] > 0 {
            buckets[counts[letter]].append(letter)
        }
        var result: [UInt8] = []
        result.reserveCapacity(bytes.count)
        for frequency in stride(from: bytes.count, through: 1, by: -1) {
            for letter in buckets[frequency] {
                result.append(contentsOf: repeatElement(UInt8(97 + letter), count: frequency))
            }
        }
        return String(decoding: result, as: UTF8.self)
    }
}
