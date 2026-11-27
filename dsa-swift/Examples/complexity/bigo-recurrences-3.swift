// Generated from src/dsa/content/lessons/complexity/bigo-recurrences.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var copied = 0

// Recursing on a copy: each call copies the rest of the array
func sumByCopying(_ numbers: [Int]) -> Int {
    guard let first = numbers.first else {
        return 0
    }
    let rest = Array(numbers.dropFirst())
    copied += rest.count
    return first + sumByCopying(rest)
}

// Recursing with an index: nothing is copied
func sumFrom(_ index: Int, in numbers: [Int]) -> Int {
    if index == numbers.count {
        return 0
    }
    return numbers[index] + sumFrom(index + 1, in: numbers)
}

for n in [10, 100, 1_000] {
    copied = 0
    let numbers = Array(1...n)
    let first = sumByCopying(numbers)
    let second = sumFrom(0, in: numbers)
    print("n = \(n): sums \(first) and \(second), elements copied \(copied)")
}
