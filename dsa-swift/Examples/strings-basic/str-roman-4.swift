// Generated from src/dsa/content/lessons/strings-basic/str-roman.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let symbolValues: [Character: Int] = ["I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000]
let table: [(value: Int, symbol: String)] = [
    (1000, "M"), (900, "CM"), (500, "D"), (400, "CD"),
    (100, "C"), (90, "XC"), (50, "L"), (40, "XL"),
    (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I"),
]

func roman(from number: Int) -> String {
    var remaining = number
    var result = ""
    for (value, symbol) in table {
        while remaining >= value {
            result += symbol
            remaining -= value
        }
    }
    return result
}

func value(of numeral: String) -> Int {
    let values = numeral.map { symbolValues[$0]! }
    var total = 0
    for index in values.indices {
        if index + 1 < values.count && values[index] < values[index + 1] {
            total -= values[index]
        } else {
            total += values[index]
        }
    }
    return total
}

var mismatches = 0
for number in 1...3999 where value(of: roman(from: number)) != number {
    mismatches += 1
}
print("mismatches:", mismatches)
