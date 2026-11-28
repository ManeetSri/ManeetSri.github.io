// Generated from src/dsa/content/lessons/backtracking/bk-partitioning.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func palindromeTable(_ letters: [Character]) -> [[Bool]] {
    let n = letters.count
    var isPalindrome = Array(repeating: Array(repeating: false, count: n), count: n)
    for i in stride(from: n - 1, through: 0, by: -1) {
        for j in i..<n where letters[i] == letters[j] && (j - i < 2 || isPalindrome[i + 1][j - 1]) {
            isPalindrome[i][j] = true
        }
    }
    return isPalindrome
}

let letters = Array("abaab")
let table = palindromeTable(letters)
for i in 0..<letters.count {
    let row = (0..<letters.count).map { j in j < i ? " " : (table[i][j] ? "T" : ".") }
    print(letters[i], row.joined(separator: " "))
}
