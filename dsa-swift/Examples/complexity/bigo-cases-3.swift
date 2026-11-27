// Generated from src/dsa/content/lessons/complexity/bigo-cases.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func insertSorted(_ value: Int, into numbers: inout [Int]) -> Int {
    numbers.append(value)
    var index = numbers.count - 1
    var shifts = 0
    while index > 0 && numbers[index - 1] > value {
        numbers[index] = numbers[index - 1]
        index -= 1
        shifts += 1
    }
    numbers[index] = value
    return shifts
}

func totalShifts(building values: [Int]) -> Int {
    var sorted: [Int] = []
    var total = 0
    for value in values {
        total += insertSorted(value, into: &sorted)
    }
    return total
}

let n = 1_000
print("ascending:", totalShifts(building: Array(1...n)))
print("descending:", totalShifts(building: Array((1...n).reversed())))
print("zigzag:", totalShifts(building: (1...n).map { $0 % 2 == 0 ? $0 : n + 1 - $0 }))
