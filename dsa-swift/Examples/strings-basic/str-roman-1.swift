// Generated from src/dsa/content/lessons/strings-basic/str-roman.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func symbolValue(_ symbol: Character) -> Int {
    switch symbol {
    case "I": return 1
    case "V": return 5
    case "X": return 10
    case "L": return 50
    case "C": return 100
    case "D": return 500
    case "M": return 1000
    default: return 0
    }
}

func value(of numeral: String) -> Int {
    let values = numeral.map(symbolValue)
    var total = 0
    for index in values.indices {
        if index + 1 < values.count && values[index] < values[index + 1] {
            total -= values[index]          // a smaller symbol before a larger one
        } else {
            total += values[index]
        }
    }
    return total
}

print(value(of: "MMXXIV"))
print(value(of: "CDXLIV"))
print(value(of: "XIV"))
