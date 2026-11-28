// Reference solution: Shortest palindrome by adding letters in front. Adding letters only in front
// keeps the longest palindromic prefix P of the text in the middle, so the answer is the reverse of
// what follows P, then the text. P is the longest prefix of s that is also a suffix of reverse(s), which
// is the last prefix-function value of s + separator + reverse(s); the separator (-1, which no byte
// equals) stops a border from running past the middle. O(n) time and space.

public enum PrependPalindrome {
    public static func shortest(from text: String) -> String {
        let s = Array(text.utf8)
        guard s.count > 1 else { return text }
        let combined = s.map { Int($0) } + [-1] + s.reversed().map { Int($0) }

        var pi = [Int](repeating: 0, count: combined.count)
        var k = 0
        for i in combined.indices.dropFirst() {
            while k > 0 && combined[i] != combined[k] { k = pi[k - 1] }
            if combined[i] == combined[k] { k += 1 }
            pi[i] = k
        }

        let palindromicPrefix = pi[combined.count - 1]
        let added = s[palindromicPrefix...].reversed()
        return String(decoding: added + s, as: UTF8.self)
    }
}
