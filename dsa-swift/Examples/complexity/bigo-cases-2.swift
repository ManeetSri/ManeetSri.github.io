// Generated from src/dsa/content/lessons/complexity/bigo-cases.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Inserts value into an already-sorted array, returning how many elements it had to shift
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

for value in [60, 35, 5] {
    var numbers = [10, 20, 30, 40, 50]
    let shifts = insertSorted(value, into: &numbers)
    print("insert \(value): \(shifts) shifts, \(numbers)")
}
