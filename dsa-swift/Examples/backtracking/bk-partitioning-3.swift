// Generated from src/dsa/content/lessons/backtracking/bk-partitioning.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func restoreAddresses(_ digits: String) -> [String] {
    let digits = Array(digits)
    var parts: [String] = []
    var result: [String] = []

    func explore(from start: Int) {
        let partsLeft = 4 - parts.count
        let digitsLeft = digits.count - start
        if partsLeft == 0 {
            if digitsLeft == 0 { result.append(parts.joined(separator: ".")) }
            return
        }
        if digitsLeft < partsLeft || digitsLeft > 3 * partsLeft { return }   // can't share them out
        for length in 1...min(3, digitsLeft) {
            let part = String(digits[start..<(start + length)])
            if length > 1 && part.first == "0" { break }   // leading zero, and longer parts keep it
            if Int(part)! > 255 { break }                  // longer parts are bigger still
            parts.append(part)                             // choose
            explore(from: start + length)                  // explore
            parts.removeLast()                             // unchoose
        }
    }

    explore(from: 0)
    return result
}

print(restoreAddresses("19216811"))
print(restoreAddresses("0000"))
print(restoreAddresses("100100"))
print(restoreAddresses("1234567890123"))
