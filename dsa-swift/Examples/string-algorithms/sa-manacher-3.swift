// Generated from src/dsa/content/lessons/string-algorithms/sa-manacher.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func manacher(_ s: [UInt8]) -> [Int] {
    var t = [Int](repeating: -1, count: 2 * s.count + 1)
    for (k, c) in s.enumerated() { t[2 * k + 1] = Int(c) }
    let n = t.count
    var rad = [Int](repeating: 0, count: n)
    var centre = 0, right = 0
    for i in 0..<n {
        if i < right { rad[i] = min(rad[2 * centre - i], right - i) }
        while i - rad[i] - 1 >= 0 && i + rad[i] + 1 < n && t[i - rad[i] - 1] == t[i + rad[i] + 1] { rad[i] += 1 }
        if i + rad[i] > right { centre = i; right = i + rad[i] }
    }
    return rad
}

// s[a..<b] is a palindrome exactly when the radius at its centre, a + b, reaches b - a
let s = Array("aacecaaa".utf8)
let rad = manacher(s)
func isPalindrome(_ a: Int, _ b: Int) -> Bool { rad[a + b] >= b - a }
print("palindromic prefixes:", (1...s.count).filter { isPalindrome(0, $0) })
print(isPalindrome(1, 6), isPalindrome(2, 5), isPalindrome(0, 8))
