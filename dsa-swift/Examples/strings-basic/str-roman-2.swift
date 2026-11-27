// Generated from src/dsa/content/lessons/strings-basic/str-roman.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

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

print(roman(from: 2024))
print(roman(from: 444))
print(roman(from: 3888))
