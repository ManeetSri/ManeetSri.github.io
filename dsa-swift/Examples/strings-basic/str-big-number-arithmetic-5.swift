// Generated from src/dsa/content/lessons/strings-basic/str-big-number-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digits(_ number: String) -> [Int] {
    number.utf8.reversed().map { Int($0 - UInt8(ascii: "0")) }
}

func text(_ digits: [Int]) -> String {
    digits.reversed().map { String($0) }.joined()
}

// Requires x ≥ y. Both least significant first.
func subtractMagnitudes(_ x: [Int], _ y: [Int]) -> [Int] {
    var result: [Int] = []
    var borrow = 0
    for place in 0..<x.count {
        var digit = x[place] - borrow - (place < y.count ? y[place] : 0)
        borrow = 0
        if digit < 0 {
            digit += 10
            borrow = 1
        }
        result.append(digit)
    }
    while result.count > 1 && result.last == 0 {
        result.removeLast()
    }
    return result
}

print(text(subtractMagnitudes(digits("1000"), digits("1"))))
print(text(subtractMagnitudes(digits("5203"), digits("4917"))))
