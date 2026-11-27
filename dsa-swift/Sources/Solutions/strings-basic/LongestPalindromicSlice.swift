// Reference solution: Longest palindromic substring. Every palindrome has a centre: a character (odd
// length) or the gap between two characters (even length). Expand outwards from all 2n - 1 centres
// while the ends match, and keep the longest. Centres are tried left to right and only a strictly
// longer palindrome replaces the best, so ties go to the leftmost. O(n²) time, O(1) extra space.

public enum LongestPalindromicSlice {
    public static func longest(in text: String) -> String {
        let chars = Array(text.utf8)
        var bestStart = 0
        var bestLength = 0

        func expand(_ low: Int, _ high: Int) {
            var low = low
            var high = high
            while low >= 0 && high < chars.count && chars[low] == chars[high] {
                low -= 1
                high += 1
            }
            // The palindrome is chars[low + 1 ... high - 1]
            let length = high - low - 1
            if length > bestLength {
                bestLength = length
                bestStart = low + 1
            }
        }

        for centre in 0..<chars.count {
            expand(centre, centre)              // odd length, centred on a character
            expand(centre, centre + 1)          // even length, centred on a gap
        }
        return String(decoding: chars[bestStart..<bestStart + bestLength], as: UTF8.self)
    }
}
